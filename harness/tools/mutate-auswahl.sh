#!/usr/bin/env bash
# mutate-auswahl.sh — waehlt die Mutations-Faelle eines Slice und verteilt sie auf Shards
# (AGENTS.md §3.6, LH-QA-03, MR-014). Kein Gate; `make mutate-auswahl` ruft es.
#
# DREI AUFRUFE:
#   urteil <kennung>                    lokal: Fallmenge ueber <Claim-Commit>..HEAD und GENAU
#                                       eine Anweisung — bei hoechstens SCHWELLE Faellen die
#                                       Zeile `make mutate MUTATE_CASES='…'` (Exit 0), bei mehr
#                                       den Push auf `mutate/<kennung>` (Exit 10).
#   shard <kennung> <shards> <index>    CI-Branch: die Faelle des Shards <index> ueber
#                                       <Claim-Commit>..HEAD, leerzeichengetrennt auf stdout.
#   shard --alle <shards> <index>       naechtlicher Vollsweep: dieselbe Zuteilung ueber alle Faelle.
# Daneben `basis <kennung>` (Claim-Commit) und `faelle <kennung>` (Fallmenge, eine je Zeile).
# Exit 2 heisst Abbruch: kein Claim-Commit, unbekannter Aufruf, nicht auswertbarer Fall.
#
# BASIS ist der Claim-Commit: der Commit, der docs/plan/planning/in-progress/<kennung>.md
# anlegt. Fehlt er, bricht der Lauf ab (fail-closed) — ein Diff gegen `main` saehe nichts,
# sobald `main` waehrend der Arbeit gepusht wurde.
#
# FALLMENGE: jeder Fall unter test/mutations/, dessen `# files:`-Angabe eine Datei aus
# `git diff --name-only <basis> HEAD` trifft, und jeder geaenderte oder neue Fall selbst.
# Die Angabe wird als Muster gegen den Pfad gehalten (muster_zu_regex), nicht gegen das
# Dateisystem aufgeloest: `*` trifft dabei auch ueber `/` hinweg, die Menge faellt also hoechstens
# groesser aus als die Aufloesung durch resolve_file_spec in mutate.sh.
#
# ZUTEILUNG: schwere Faelle — die Modi der seriellen Spur von mutate.sh, erhoben ueber dessen
# case_mode und plan_self_contained, keine zweite Liste — gehen reihum auf die Shards, nach
# Namen sortiert. Danach geht jeder leichte Fall, schwerster zuerst, auf den Shard mit der
# geringsten Last (bei Gleichstand der niedrigste Index). Die Last ist die Summe der Gewichte
# aus fall_gewicht.
#
# GRENZEN: Ein Fall, dessen Waechter-Test geaendert wurde, dessen `# files:` aber keine
# geaenderte Datei nennt, faellt nicht in die Menge; ebenso ein Fall, dessen `# files:` auf die
# falsche Datei zeigt. Das lokale Urteil misst HEAD, nicht den Arbeitsbaum. Die Gewichte sind
# eine Annahme ueber die Wanduhr je Sensor; ihre Messung ist report_times in mutate.sh.
#
# Sensor: test/mutate-auswahl.bats.
set -euo pipefail

AUSWAHL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=harness/tools/mutate.sh
source "$AUSWAHL_DIR/mutate.sh"
FAELLE_DIR="${MUTATE_AUSWAHL_FAELLE:-$REPO/test/mutations}"

# SCHWELLE: hoechstens so viele Faelle laufen lokal, ab einem mehr laeuft der Slice ueber den
# CI-Branch. Setzung des Auftraggebers; die Anweisungssaetze nennen die Zahl nicht.
SCHWELLE=8

abbruch() {
  echo "mutate-auswahl: ABBRUCH — $1" >&2
  exit 2
}

# basis_commit liefert den Claim-Commit der Kennung <1> oder bricht ab.
basis_commit() {
  local kennung="$1" basis
  [ -n "$kennung" ] || abbruch "keine Slice-Kennung angegeben"
  basis="$(git -C "$REPO" log --no-renames --diff-filter=A --format=%H -1 -- \
    "docs/plan/planning/in-progress/$kennung.md")" || abbruch "git log ueber den Claim-Commit von $kennung scheiterte"
  [ -n "$basis" ] || abbruch "kein Claim-Commit fuer $kennung — kein Commit legt docs/plan/planning/in-progress/$kennung.md an"
  printf '%s\n' "$basis"
}

# muster_zu_regex macht aus einer `# files:`-Angabe einen verankerten regulaeren Ausdruck:
# `*` trifft beliebig viele Zeichen (auch `/`), `?` genau eines, alles andere woertlich.
muster_zu_regex() {
  printf '^%s$' "$(sed -e 's/[][\.^$+(){}|]/\\&/g' -e 's/\*/.*/g' -e 's/?/./g' <<<"$1")"
}

# faelle_ueber liest geaenderte Pfade von stdin und gibt die getroffenen Fall-Namen sortiert aus.
faelle_ueber() {
  local -a geaendert=()
  local f case_file name spec
  mapfile -t geaendert
  for case_file in "$FAELLE_DIR"/*.sh; do
    name="$(basename "$case_file" .sh)"
    for f in "${geaendert[@]}"; do
      if [ "$f" = "test/mutations/$name.sh" ]; then
        printf '%s\n' "$name"
        continue 2
      fi
      while IFS= read -r spec; do
        [ -n "$spec" ] || continue
        if [[ "$f" =~ $(muster_zu_regex "$spec") ]]; then
          printf '%s\n' "$name"
          continue 3
        fi
      done < <(sed -n 's/^# files: //p' "$case_file" | tr ' ' '\n')
    done
  done | LC_ALL=C sort -u
}

faelle_fuer() {
  local basis
  basis="$(basis_commit "$1")" || exit 2
  git -C "$REPO" diff --name-only "$basis" HEAD | faelle_ueber
}

alle_faelle() {
  local case_file
  for case_file in "$FAELLE_DIR"/*.sh; do basename "$case_file" .sh; done | LC_ALL=C sort
}

# fall_gewicht: angenommene Wanduhr eines Falls je Sensor-Modus, in Sekunden.
fall_gewicht() {
  case "$1" in
    full-smoke) printf '%s' 210 ;;
    test) printf '%s' 150 ;;
    smoke) printf '%s' 90 ;;
    test-go) printf '%s' 60 ;;
    test-bats) printf '%s' 25 ;;
    ci-lint) printf '%s' 10 ;;
    *) printf '%s' 30 ;;
  esac
}

# zuteilen liest Fall-Namen von stdin und gibt `<name>\t<shard>` aus, fuer <1> Shards.
zuteilen() {
  local shards="$1" name mode schwer gewicht
  local -A schwer_je_modus=()
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    [ -f "$FAELLE_DIR/$name.sh" ] || abbruch "Fall $name existiert nicht unter $FAELLE_DIR"
    mode="$(case_mode "$FAELLE_DIR/$name.sh")"
    if [ -z "${schwer_je_modus[$mode]+x}" ]; then
      if [ "$mode" != "-" ] && ! plan_self_contained "$mode"; then
        schwer_je_modus[$mode]=1
      else
        schwer_je_modus[$mode]=0
      fi
    fi
    schwer="${schwer_je_modus[$mode]}"
    gewicht="$(fall_gewicht "$mode")"
    printf '%s\t%s\t%s\n' "$schwer" "$gewicht" "$name"
  done | LC_ALL=C sort -t$'\t' -k1,1nr -k2,2nr -k3,3 | awk -F'\t' -v n="$shards" '
    BEGIN { for (s = 0; s < n; s++) last[s] = 0 }
    $1 == 1 { s = k % n; k++; last[s] += $2; print $3 "\t" s; next }
    {
      best = 0
      for (s = 1; s < n; s++) if (last[s] < last[best]) best = s
      last[best] += $2
      print $3 "\t" best
    }'
}

shard_faelle() {
  local shards="$2" index="$3" menge
  [[ "$shards" =~ ^[1-9][0-9]*$ ]] || abbruch "Shard-Zahl '$shards' ist keine ganze Zahl >= 1"
  [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -lt "$shards" ] || abbruch "Shard-Index '$index' liegt nicht in 0..$((shards - 1))"
  if [ "$1" = "--alle" ]; then menge="$(alle_faelle)"; else menge="$(faelle_fuer "$1")" || exit 2; fi
  zuteilen "$shards" <<<"$menge" | awk -F'\t' -v i="$index" '$2 == i { printf "%s ", $1 }' | sed 's/ $//'
  echo
}

urteil() {
  local kennung="$1" menge n
  menge="$(faelle_fuer "$kennung")" || exit 2
  n=0
  if [ -n "$menge" ]; then n="$(printf '%s\n' "$menge" | wc -l)"; fi
  echo "mutate-auswahl: $n Fall/Faelle ueber $(basis_commit "$kennung" | cut -c1-12)..HEAD (Schwelle $SCHWELLE lokal)"
  if [ "$n" -eq 0 ]; then
    echo "mutate-auswahl: kein Fall beruehrt — kein Lauf noetig."
    return 0
  fi
  local -a liste
  mapfile -t liste <<<"$menge"
  printf '  %s\n' "${liste[@]}"
  if [ "$n" -gt "$SCHWELLE" ]; then
    echo "mutate-auswahl: CI-Branch — git push -f origin HEAD:refs/heads/mutate/$kennung"
    echo "mutate-auswahl: Ergebnis danach: git fetch origin mutate/$kennung && git show FETCH_HEAD:mutate-ergebnis.txt"
    return 10
  fi
  echo "mutate-auswahl: lokal — make mutate MUTATE_CASES='$(printf '%s\n' "$menge" | paste -sd' ')'"
}

# --- CI-Branch (.github/workflows/mutate-branch.yml) --------------------------------------
# ERGEBNIS heisst die Datei an der Branch-Wurzel, die der Schritt `ergebnis` schreibt.
ERGEBNIS="mutate-ergebnis.txt"

# kennung_aus_ref liefert die Slice-Kennung aus dem Ref-Namen <1> oder bricht ab, wenn der
# Ref nicht mit `mutate/` beginnt — der Schreibschritt beschreibt keinen anderen Branch.
kennung_aus_ref() {
  case "$1" in
    mutate/?*) printf '%s\n' "${1#mutate/}" ;;
    *) abbruch "Ref '$1' beginnt nicht mit mutate/ — kein Lauf, kein Push" ;;
  esac
}

# lauf_pruefen gibt `kennung=…` und `laufen=true|false` aus (Zeilen fuer GITHUB_OUTPUT).
# `false` heisst: der Tip aendert gegenueber seinem Vorgaenger allein die Ergebnisdatei.
lauf_pruefen() {
  local kennung geaendert
  kennung="$(kennung_aus_ref "$1")" || exit 2
  geaendert="$(git -C "$REPO" diff --name-only HEAD^ HEAD 2>/dev/null || true)"
  printf 'kennung=%s\n' "$kennung"
  if [ "$geaendert" = "$ERGEBNIS" ]; then
    echo "laufen=false"
    echo "mutate-auswahl: Tip aendert allein $ERGEBNIS — kein Lauf." >&2
  else
    echo "laufen=true"
  fi
}

# shard_lauf faehrt die Faelle des Shards <3> von <2> fuer die Kennung <1> und legt unter <4>
# den Beleg ab: faelle, start, ende (Epoch-Sekunden), rc, log. Exit 0 auch bei Befund — der
# Beleg schreibt immer, das Urteil faellt im Schritt `ergebnis`.
shard_lauf() {
  local kennung="$1" shards="$2" index="$3" aus="$4" faelle rc=0
  mkdir -p "$aus"
  faelle="$(shard_faelle "$kennung" "$shards" "$index")" || exit 2
  printf '%s\n' "$faelle" >"$aus/faelle"
  date +%s >"$aus/start"
  if [ -n "$faelle" ]; then
    ( cd "$REPO" && MUTATE_CASES="$faelle" make --no-print-directory mutate ) >"$aus/log" 2>&1 || rc=$?
    cat "$aus/log"
  else
    echo "mutate-auswahl: Shard $index hat keine Faelle." | tee "$aus/log"
  fi
  echo "$rc" >"$aus/rc"
  date +%s >"$aus/ende"
}

# ergebnis_schreiben setzt aus den Shard-Belegen unter <3>/shard-<i>/ die Ergebnisdatei
# zusammen, committet sie ueber HEAD und pusht nach refs/heads/<1> — ohne --force. Exit 1,
# wenn ein Fall einen Befund oder kein Ergebnis traegt, nach dem Push.
ergebnis_schreiben() {
  local ref="$1" shards="$2" dir="$3" kennung basis commit i d f st n=0 befund=0
  local -a liste=()
  local start_min="" ende_max=""
  kennung="$(kennung_aus_ref "$ref")" || exit 2
  basis="$(basis_commit "$kennung")" || exit 2
  commit="$(git -C "$REPO" rev-parse HEAD)"
  {
    echo "mutate-ergebnis: $kennung"
    echo "gepruefter Commit: $commit"
    echo "Basis (Claim-Commit): $basis"
    for ((i = 0; i < shards; i++)); do
      d="$dir/shard-$i"
      if [ ! -f "$d/rc" ]; then
        echo "Shard $i: KEIN BELEG"
        befund=1
        continue
      fi
      echo "Shard $i: Exit $(cat "$d/rc"), $(($(cat "$d/ende") - $(cat "$d/start"))) s, Faelle: $(cat "$d/faelle")"
      if [ -z "$start_min" ] || [ "$(cat "$d/start")" -lt "$start_min" ]; then start_min="$(cat "$d/start")"; fi
      if [ -z "$ende_max" ] || [ "$(cat "$d/ende")" -gt "$ende_max" ]; then ende_max="$(cat "$d/ende")"; fi
    done
    for ((i = 0; i < shards; i++)); do
      d="$dir/shard-$i"
      [ -f "$d/faelle" ] || continue
      read -r -a liste <"$d/faelle" || true
      for f in "${liste[@]}"; do
        n=$((n + 1))
        if grep -qE "^mutate: ok +$f( |$)" "$d/log"; then st="ok"
        elif grep -qE "^mutate: BEFUND +$f( |$)" "$d/log"; then st="BEFUND"; befund=1
        else st="BEFUND (kein Ergebnis im Log)"; befund=1
        fi
        printf '%-8s %-56s Shard %s\n' "$st" "$f" "$i"
      done
    done
    echo "Fallmenge: $n"
    if [ -n "$start_min" ]; then echo "Wanduhr gesamt (erster Shard-Start bis letztes Shard-Ende): $((ende_max - start_min)) s"; fi
    if [ "$befund" -eq 0 ]; then echo "Urteil: gruen"; else echo "Urteil: BEFUND"; fi
  } >"$REPO/$ERGEBNIS"
  cat "$REPO/$ERGEBNIS"
  git -C "$REPO" add -- "$ERGEBNIS"
  git -C "$REPO" -c user.name='github-actions[bot]' \
    -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
    commit -q -m "mutate-ergebnis: $kennung @ ${commit:0:12} (MR-014)" -- "$ERGEBNIS"
  git -C "$REPO" push origin "HEAD:refs/heads/$ref"
  [ "$befund" -eq 0 ]
}

auswahl_main() {
  case "${1:-}" in
    lauf) lauf_pruefen "${2:-}" ;;
    shard-lauf) [ "$#" -eq 5 ] || abbruch "shard-lauf braucht <kennung> <shards> <index> <verzeichnis>"; shard_lauf "$2" "$3" "$4" "$5" ;;
    ergebnis) [ "$#" -eq 4 ] || abbruch "ergebnis braucht <ref> <shards> <verzeichnis>"; ergebnis_schreiben "$2" "$3" "$4" ;;
    urteil) urteil "${2:-}" ;;
    shard) [ "$#" -eq 4 ] || abbruch "shard braucht <kennung|--alle> <shards> <index>"; shard_faelle "$2" "$3" "$4" ;;
    basis) basis_commit "${2:-}" ;;
    faelle) faelle_fuer "${2:-}" ;;
    *) abbruch "unbekannter Aufruf '${1:-}' — urteil | shard | basis | faelle" ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  auswahl_main "$@"
fi
