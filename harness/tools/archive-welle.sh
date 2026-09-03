#!/usr/bin/env bash
# archive-welle.sh — Schritt 4 der Wellen-Closure als Operation: die
# Zeitdokumente einer geschlossenen Welle wandern in ein Archiv, an ihrer
# Stelle bleiben gekuerzte Stubs.
#
# RANG-ZEIGER. Was archiviert wird, was liegen bleibt und in welcher Form,
# steht im Baseline-Regelwerk (modul-06-roadmap.md, §Wellen-Closure-Prozedur,
# Schritt 4). Die Ziel-Form der zwei Stubs liegt als Vorlage im vendored Baum
# und wird per `cp` genommen, nicht nachgebaut.
#
# ZUSAGE. `make archive-welle WELLE=<welle-id>` legt
# docs/plan/planning/done/<welle-id>/archiv.zip an, ersetzt jede eingesammelte
# Slice-Datei und den Welle-Plan durch einen Stub im selben Verzeichnis,
# entfernt die eingesammelten Review-Reports ohne Stub und zieht die Verweise
# auf die bewegten Dateien in beiden Formen nach — mit Verzeichnis-Praefix und
# geschwister-relativ (praefixlos). Move und Inhalt liegen in zwei getrennten
# Commits (AGENTS.md 3.3): Commit 1 ist ein reiner `git mv` ohne ein Byte
# Inhalt, Commit 2 traegt Archiv, Stubs und Verweis-Nachzug.
# test/archive-welle.bats deckt die Einsammel-Regel, die Stub-Form, die
# Stub-Erzeugung aus der Vorlage und beide Ersetzungsrichtungen ueber
# synthetischen Proben ab, ohne ein Repo zu bewegen; main() braucht ein echtes
# `git`-Repo und Docker und laeuft dort nicht mit.
#
# EINSAMMEL-REGEL (sie liegt hier, nicht im Aufrufer). Prueffeld sind die
# flachen `slice-*.md` unter docs/plan/planning/done/. Das Kopf-Feld
# `**Welle:**` entscheidet in drei Klassen:
#   mitglied   — das Feld nennt <welle-id>            -> eingesammelt
#   wellenlos  — das Feld sagt "ohne Welle"           -> eingesammelt
#   fremd      — das Feld nennt eine andere Welle
#                oder gar keine ("—")                 -> bleibt liegen
# Dazu der Welle-Plan (done/<welle-id>*.md ausser der Ergebnisnotiz) und die
# Review-Reports, deren Dateiname die Nummer eines eingesammelten Slice traegt.
# Die Ergebnisnotiz bleibt vollstaendig und flach.
#
# VORAUSSETZUNG. Das Skript committet selbst und verlangt darum einen sauberen
# Arbeitsbaum, bevor es startet — sonst landet ein fremder Diff im Move- oder
# im Inhalts-Commit. Ein Verstoss bricht den Aufruf vor dem ersten `git mv`.
#
# DOCKER-ONLY. Gepackt wird mit `git archive --format=zip` im gepinnten Bild
# (ARCHIVE_IMAGE), ueber einen read-only gemounteten Baum und mit Ausgabe auf
# stdout — der packende Container kann den Baum nicht anfassen. Zwei Laeufe
# ueber denselben Commit liefern dieselben Bytes; die Eintrags-Zeitstempel
# stammen aus der Commit-Zeit des Tree-Operanden, nicht aus der Uhr des Laufs.
#
# BELEG. main() braucht `git` und `docker` und laeuft darum in keinem
# bats-Fall (das gepinnte BATS_IMAGE fuehrt beides nicht). Der Beleg ist ein
# eigenes Scratch-Repo mit drei Slices — einem Mitglied, einem wellenlosen,
# zwei fremden —, einem Welle-Plan, einer Ergebnisnotiz, einem Review-Report
# und einer frueher archivierten Welle als Untergrenze:
#   `git show --stat` auf Commit 1 zeigt drei reine Renames,
#     0 insertions / 0 deletions;
#   Commit 2 traegt archiv.zip, drei Stubs, den geloeschten Review-Report und
#     zwei Verweis-Nachzuege (Praefix-Form in der Ergebnisnotiz, geschwister-
#     relative Form in einer flach gebliebenen Nachbar-Datei);
#   der wellenlose Slice ist eingesammelt, die zwei fremden liegen unberuehrt
#     flach in done/;
#   `sha256sum` ueber zwei `git archive`-Laeufe desselben Tree-Operanden ist
#     gleich — deshalb steht oben "dieselben Bytes" und nicht "aehnliche".
# Die vier fail-closed-Ausgaenge sind an demselben Repo gefahren: Altbestand
# ohne Untergrenze und lebender Verweis auf einen zu loeschenden Review-Report
# brechen mit 3 ab, "schon archiviert" und "unsauberer Baum" mit 2.
#
# GRENZEN (fuenf, gemessen):
# (1) ALTBESTAND. "wellenlos seit der letzten Closure" hat nur dort eine
#     beobachtbare Untergrenze, wo schon einmal archiviert wurde. Solange kein
#     done/<welle-id>/archiv.zip existiert, umfasst die Klasse `wellenlos`
#     jeden wellenlosen Slice, den das Repo je geschlossen hat. Das Skript
#     raet dann nicht, sondern bricht ab (Ausgang 3) und nennt den Vorgang,
#     der die Grenze setzt: die Archivierung des Altbestands, je geschlossener
#     Welle einmal oder als ein Sammel-Archiv.
# (2) Es zieht PFADE nach, keine ZUSTANDSSAETZE. Ein Satz "liegt in `done/`"
#     bleibt nach dem Umzug stehen; sein Verweis wird richtig, seine Aussage
#     ungenau. Welcher Satz einen Zustand behauptet, ist Urteil, kein Match.
# (3) Ein eingehender Verweis in INLINE-CODE ohne Verzeichnis-Segment
#     (`slice-N….md` als Pfad-Span statt als Link-Ziel) wird nicht
#     nachgezogen: die geschwister-relative Ersetzung ankert an der
#     Link-Klammer `](…)`. `make docs-check` nach dem Lauf zeigt den Rest.
# (4) Das Feld `Geschlossen:` eines Slice-Stubs nimmt das Datum aus der
#     `**Rolle:** … **Datum:**`-Zeile der Closure-Notiz; traegt die Datei
#     keine, steht dort das Abschluss-Datum der archivierenden Welle.
# (5) Aus der Vorlage uebernimmt der Stub H1, den Archiv-Zeiger und den
#     Feld-Block — die drei Teile, die die Ziel-Form ausmachen. Die
#     Erlaeuterungs-Absaetze der Vorlage schreiben an den Kopierenden und
#     fallen weg wie ihr Bedienhinweis (templates/README.md §Verwendung,
#     Schritte 4 und 5); in hundert Stubs waeren sie hundert Kopien einer
#     Norm, die an einer Stelle lebt.
#
# KOPPLUNG. Der Stub liegt unter docs/plan/planning/done/<welle-id>/ und faellt
# damit unter zwei Regeln dieses Repos, die eine Ebene hoeher schon galten: die
# ID-Link-Pflicht (.d-check.yml, ids.link-policy) — deshalb baut
# feld_hervorgegangen() jede Kennung als Anker-Link statt sie abzuschreiben —
# und die matrix-Klasse `slice`, deren Glob `**` auch zwei Ebenen tief greift.
set -euo pipefail

PLANNING="docs/plan/planning"
DONE="$PLANNING/done"
REVIEWS="docs/reviews"

usage() {
  cat >&2 <<'USAGE'
Aufruf: make archive-welle WELLE=<welle-id>

  Archiviert die Zeitdokumente einer GESCHLOSSENEN Welle: Slice-Dateien,
  Welle-Plan und Review-Reports wandern nach
  docs/plan/planning/done/<welle-id>/archiv.zip, an der Stelle von Slice und
  Plan bleibt je ein gekuerzter Stub. Die Ergebnisnotiz bleibt vollstaendig
  und flach. Verlangt einen sauberen Arbeitsbaum. Grenzen: siehe Skriptkopf.
USAGE
}

# Erweiterte Regex-Metazeichen im Dateinamen entschaerfen — ein Dateiname
# traegt mindestens einen Punkt (die Endung ".md"), der in ERE sonst "ein
# beliebiges Zeichen" bedeutet statt sich selbst.
re_escape() {
  printf '%s' "$1" | sed -e 's/[][\.^$*+?(){}|\\]/\\&/g'
}

# Ein Feld-Wert landet in der RECHTEN Haelfte eines sed-Ausdrucks. Dort sind
# drei Zeichen besonders: der Backslash, das '&' (Rueckverweis auf den Treffer)
# und das '#' (der hier gewaehlte Trenner). Parameter-Ersetzung statt einer
# sed-Pipe — ein Wert wie "[`ADR-0028`](…)" traegt keine Zeilenumbrueche.
sed_ersatz() {  # $1=text
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//&/\\&}"
  s="${s//\#/\\#}"
  printf '%s' "$s"
}

# Der Rohtext hinter dem Kopf-Feld `**Welle:**`, aus der ERSTEN Zeile, die es
# traegt. Leer, wenn die Datei kein solches Feld fuehrt.
welle_feld() {  # $1=datei
  sed -n 's/^\*\*Welle:\*\*[[:space:]]*//p' "$1" | head -n 1
}

# Die Klasse einer Slice-Datei fuer diese Welle: mitglied | wellenlos | fremd.
# Die Welle-Kennung wird an einer ZIFFERN-Grenze verglichen: "welle-02" trifft
# die Langform "welle-02-fetch-und-readme", "welle-1" trifft "welle-14" nicht.
klasse_von() {  # $1=datei $2=welle-id
  local feld esc
  feld="$(welle_feld "$1")"
  esc="$(re_escape "$2")"
  if printf '%s' "$feld" | grep -qE "(^|[^A-Za-z0-9_-])$esc([^0-9]|$)"; then
    printf 'mitglied\n'
  elif printf '%s' "$feld" | grep -qE '^ohne Welle([^A-Za-z]|$)'; then
    printf 'wellenlos\n'
  else
    printf 'fremd\n'
  fi
}

# Die Form-Pruefung des Stubs: er traegt den Archiv-Zeiger UND keine
# Abschnittsueberschrift mehr. Die zweite Haelfte ist die tragende — ein Stub
# mit Zeiger und vollem Text waere die Archivierung, die nicht stattfand.
# Gibt bei Verstoss den Grund auf stderr aus und liefert 1.
stub_form_ok() {  # $1=datei
  local rc=0
  if ! grep -q '^> \*\*ARCHIVIERT\*\*' "$1" || ! grep -q 'archiv\.zip' "$1"; then
    echo "archive-welle: $1 traegt keinen Archiv-Zeiger (> **ARCHIVIERT** … archiv.zip)" >&2
    rc=1
  fi
  if grep -q '^##' "$1"; then
    echo "archive-welle: $1 traegt noch Abschnittsueberschriften — gekuerzt ist er damit nicht" >&2
    rc=1
  fi
  return "$rc"
}

# EINGEHEND mit Verzeichnis-Praefix: jedes Vorkommen von "$von/$base" wird zu
# "$nach/$base", an einer Wortgrenze (Zeilenanfang oder ein Zeichen davor, das
# kein Wortzeichen ist — Bindestrich zaehlt mit, weil Verzeichnisnamen wie
# "in-progress" einen tragen). Eine Regel statt einer Praefix-Liste: sie deckt
# jede Aufstiegstiefe und jeden Kontext.
rewrite_incoming_in_file() {  # $1=datei $2=base $3=von $4=nach
  local file="$1" base="$2" von="$3" nach="$4" esc_base
  esc_base="$(re_escape "$base")"
  sed -i -E "s#(^|[^A-Za-z0-9_-])$von/$esc_base#\\1$nach/$base#g" "$file"
}

# EINGEHEND geschwister-relativ: ein Link-Ziel OHNE Verzeichnis-Segment
# ("](slice-N….md)") zeigt auf einen Geschwister im selben Verzeichnis. Zieht
# die bewegte Datei eine Ebene tiefer, bekommt das Ziel das Praefix vorgesetzt.
# Diese Form kennt der Lifecycle-Move nicht — dort fehlt das
# Verzeichnis-Literal, an dem die Praefix-Regel ankert; hier ist es die
# Link-Klammer. Gibt die Anzahl der umgehaengten Vorkommen auf stdout aus.
#
# Gezaehlt wird mit `grep -oE`, nicht mit `-oF`: das busybox-grep des gepinnten
# bats-Bildes meldet bei `-oF` hoechstens einen Treffer je ZEILE, das
# GNU-grep des Hosts alle. Zwei Ziele in derselben Zeile sind der Regelfall.
rewrite_bare_sibling_in_file() {  # $1=datei $2=base $3=praefix
  local file="$1" base="$2" praefix="$3" esc_base n
  esc_base="$(re_escape "$base")"
  n="$(grep -oE "\\]\\($esc_base\\)" "$file" 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$n" -gt 0 ]; then
    sed -i -E "s#\\]\\($esc_base\\)#](${praefix}${base})#g" "$file"
  fi
  printf '%d\n' "$n"
}

# Die Slice-Nummer aus einem Dateinamen ("slice-170-titel.md" -> "170").
slice_nummer() {  # $1=basename
  printf '%s' "$1" | sed -n 's/^slice-\([0-9][0-9]*\).*/\1/p'
}

# Der Titel aus der H1-Zeile, ohne die Kennung davor. Getroffen werden die
# Formen "# Slice slice-NNN: T", "# slice-NNN — T", "# Welle welle-NN: T" und
# "# welle-NN — T"; traegt die Zeile keine Kennung, bleibt sie ganz stehen.
titel_von() {  # $1=datei
  head -n 1 "$1" \
    | sed -E -e 's/^#[[:space:]]*//' \
             -e 's/^(Slice|Welle)[[:space:]]+//' \
             -e 's/^(slice|welle)-[0-9]+[A-Za-z0-9-]*[[:space:]]*[:—-][[:space:]]*//'
}

# Das Abschluss-Datum eines Slice: die Closure-Notiz traegt es in ihrer
# `**Rolle:** … **Datum:**`-Zeile. Fehlt die Zeile, gilt der uebergebene
# Ersatzwert (Grenze 4 im Skriptkopf).
geschlossen_datum() {  # $1=datei $2=ersatz
  local d
  d="$(sed -n 's/^\*\*Rolle:\*\*.*\*\*Datum:\*\*[[:space:]]*\([0-9-]\{10\}\).*/\1/p' "$1" | tail -n 1)"
  printf '%s\n' "${d:-$2}"
}

# Der relative Pfad von docs/plan/planning/done/<welle-id>/ zu einer
# Slice-Datei, die noch irgendwo im Lifecycle liegt. Leer, wenn keine da ist —
# dann steht die Kennung im Stub ohne Link, statt einen toten zu erfinden.
slice_pfad_relativ() {  # $1=nummer $2=welle-id
  local n="$1" welle="$2" f d
  for f in "$DONE/$welle/slice-$n-"*.md; do
    if [ -e "$f" ]; then basename "$f"; return 0; fi
  done
  for f in "$DONE/slice-$n-"*.md; do
    if [ -e "$f" ]; then printf '../%s\n' "$(basename "$f")"; return 0; fi
  done
  for f in "$DONE"/*/"slice-$n-"*.md; do
    if [ -e "$f" ]; then
      d="$(basename "$(dirname "$f")")"
      printf '../%s/%s\n' "$d" "$(basename "$f")"
      return 0
    fi
  done
  for d in open next in-progress; do
    for f in "$PLANNING/$d/slice-$n-"*.md; do
      if [ -e "$f" ]; then printf '../../%s/%s\n' "$d" "$(basename "$f")"; return 0; fi
    done
  done
  printf '\n'
}

# Der Wert des Stub-Felds `Hervorgegangen:` — die Kennungen, die den Vorgang
# ueberlebt haben. Quelle sind die zwei Zeilen der Closure-Notiz, die einen
# Ausgang tragen: die Register-Zeile und die Folge-Slice-Zeile. Jede Kennung
# wird als Anker-Link neu gebaut, nicht abgeschrieben — die Pfade der Vorlage
# gelten fuer eine Ebene hoeher, und die ID-Link-Pflicht gilt im Stub
# (Kopplung im Skriptkopf).
feld_hervorgegangen() {  # $1=datei $2=welle-id
  local file="$1" welle="$2" zeilen id f adr pfad out=""
  local -a teile=()
  zeilen="$(grep -E '^- \*\*(Beobachtungs-Register|Folge-Slices)' "$file" || true)"
  if [ -z "$zeilen" ]; then printf -- '— keine —\n'; return 0; fi

  while IFS= read -r id; do
    [ -n "$id" ] || continue
    teile+=("[\`$id\`](../../observations.md)")
  done < <(printf '%s\n' "$zeilen" | grep -oE 'BEO-[0-9]{3}' | sort -u || true)

  while IFS= read -r id; do
    [ -n "$id" ] || continue
    adr=""
    for f in "docs/plan/adr/${id#ADR-}-"*.md; do
      if [ -e "$f" ]; then adr="$(basename "$f")"; break; fi
    done
    [ -n "$adr" ] && teile+=("[\`$id\`](../../../adr/$adr)")
  done < <(printf '%s\n' "$zeilen" | grep -oE 'ADR-[0-9]{4}' | sort -u || true)

  while IFS= read -r id; do
    [ -n "$id" ] || continue
    pfad="$(slice_pfad_relativ "${id#slice-}" "$welle")"
    if [ -n "$pfad" ]; then teile+=("[$id]($pfad)"); else teile+=("$id"); fi
  done < <(printf '%s\n' "$zeilen" | grep -E '^- \*\*Folge-Slices' | grep -oE 'slice-[0-9]{3}' | sort -u || true)

  if [ "${#teile[@]}" -eq 0 ]; then
    printf -- '— keine —\n'
    return 0
  fi
  for id in "${teile[@]}"; do
    if [ -z "$out" ]; then out="$id"; else out="$out · $id"; fi
  done
  printf '%s\n' "$out"
}

# Der vendored Vorlagen-Baum. Der <tag> wird ENTDECKT, nicht geraten — so steht
# der Tag-String allein in BASELINE_TAG (Makefile), wie bei baseline-verify.
templates_dir() {
  local base=".harness/baseline"
  local -a dirs
  shopt -s nullglob
  dirs=("$base"/*/)
  shopt -u nullglob
  if [ "${#dirs[@]}" -ne 1 ]; then
    echo "archive-welle: erwartet genau ein <tag>-Verzeichnis unter $base/ (gefunden: ${#dirs[@]})" >&2
    return 1
  fi
  printf '%s\n' "${dirs[0]}templates/docs/plan/planning"
}

# Aus der Vorlage wird der Stub: kopieren, dann die drei Teile herausziehen,
# die die Ziel-Form ausmachen (H1 · Archiv-Zeiger-Block · letzter Absatz mit
# den Feld-Zeilen), und ihre Platzhalter ersetzen. Was dazwischen liegt,
# schreibt an den Kopierenden und faellt weg (Grenze 5 im Skriptkopf).
# Die Ersetzungen laufen in fester Reihenfolge: die zusammengesetzten
# Platzhalter zuerst, sonst frisst `<welle-id>` seine eigenen Nachbarn.
stub_aus_vorlage() {  # $1=vorlage $2=ziel $3=welle $4=zip $5=pfad-im-archiv $6..=sed-ausdruecke
  local vorlage="$1" ziel="$2" welle="$3" zip="$4" imarchiv="$5"
  shift 5
  if [ ! -f "$vorlage" ]; then
    echo "archive-welle: Vorlage fehlt: $vorlage" >&2
    return 1
  fi
  cp "$vorlage" "$ziel"
  local roh
  roh="$(awk '
    NR == 1 { h1 = $0; next }
    /^> \*\*ARCHIVIERT\*\*/ { inzeiger = 1 }
    inzeiger && /^$/ { inzeiger = 0; next }
    inzeiger { zeiger = zeiger $0 "\n"; next }
    /^$/ { absatz = ""; next }
    { absatz = absatz $0 "\n" }
    END { printf "%s\n\n%s\n%s", h1, zeiger, absatz }
  ' "$ziel")"
  local ausdruck
  printf '%s\n' "$roh" > "$ziel"
  for ausdruck in "$@"; do
    sed -i -e "$ausdruck" "$ziel"
  done
  sed -i \
    -e "s#done/<welle-id>/archiv\.zip#$zip#g" \
    -e "s#<pfad-im-archiv>#$imarchiv#g" \
    -e "s#<welle-id>#$welle#g" \
    "$ziel"
}

main() {
  local WELLE="${1:-}"
  if [ -z "$WELLE" ]; then usage; exit 2; fi

  cd "$(dirname "$0")/../.."

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "archive-welle: Arbeitsbaum nicht sauber — erst committen oder stashen (das Skript committet selbst, siehe Skriptkopf VORAUSSETZUNG)" >&2
    exit 2
  fi

  local ziel="$DONE/$WELLE"
  if [ -e "$ziel" ]; then
    echo "archive-welle: $ziel gibt es schon — diese Welle ist archiviert" >&2
    exit 2
  fi

  local results="$DONE/$WELLE-results.md"
  if [ ! -f "$results" ]; then
    echo "archive-welle: $results fehlt — Schritt 4 folgt auf Schritt 3, die Ergebnisnotiz ist seine Vorbedingung" >&2
    exit 2
  fi

  # Der Welle-Plan: done/<welle-id>*.md ohne die Ergebnisnotiz, genau einer.
  local plan="" f
  for f in "$DONE/$WELLE"*.md; do
    [ -e "$f" ] || continue
    [ "$f" = "$results" ] && continue
    if [ -n "$plan" ]; then
      echo "archive-welle: mehrdeutiger Welle-Plan — $plan und $f" >&2
      exit 2
    fi
    plan="$f"
  done
  if [ -z "$plan" ]; then
    echo "archive-welle: kein Welle-Plan '$WELLE*' in $DONE/ (er wandert bei Schritt 3 dorthin)" >&2
    exit 2
  fi

  # Einsammeln nach der Regel im Skriptkopf.
  local -a mitglieder=() wellenlose=() fremde=()
  local klasse
  for f in "$DONE"/slice-*.md; do
    [ -e "$f" ] || continue
    klasse="$(klasse_von "$f" "$WELLE")"
    case "$klasse" in
      mitglied)  mitglieder+=("$f") ;;
      wellenlos) wellenlose+=("$f") ;;
      *)         fremde+=("$f") ;;
    esac
  done

  # Grenze 1: ohne ein vorhandenes Archiv hat "seit der letzten Closure" keine
  # beobachtbare Untergrenze. Fail-closed statt raten.
  if [ "${#wellenlose[@]}" -gt 0 ]; then
    local -a bestehende=()
    for f in "$DONE"/*/archiv.zip; do
      [ -e "$f" ] && bestehende+=("$f")
    done
    if [ "${#bestehende[@]}" -eq 0 ]; then
      echo "archive-welle: ${#wellenlose[@]} wellenlose Slice(s) liegen flach in $DONE/, aber kein $DONE/*/archiv.zip setzt eine Untergrenze." >&2
      echo "  'wellenlos seit der letzten Closure' umfasste damit den gesamten Altbestand. Diese Zuordnung liefert die Regel nicht;" >&2
      echo "  sie ist ein eigener Vorgang (je geschlossener Altwelle einmal, oder ein Sammel-Archiv). Danach ist die Grenze beobachtbar." >&2
      exit 3
    fi
  fi

  local -a slices=("${mitglieder[@]}" "${wellenlose[@]}")
  if [ "${#slices[@]}" -eq 0 ]; then
    echo "archive-welle: kein Slice fuer '$WELLE' eingesammelt — nichts zu archivieren" >&2
    exit 2
  fi

  # Review-Reports zu den eingesammelten Slices: der Dateiname traegt die
  # Nummer. Sie bekommen keinen Stub — sie haben keine Identitaet neben ihrem
  # Slice.
  local -a reviews=()
  local nr r
  for f in "${slices[@]}"; do
    nr="$(slice_nummer "$(basename "$f")")"
    [ -n "$nr" ] || continue
    for r in "$REVIEWS"/*"slice-$nr"*.md; do
      [ -e "$r" ] && reviews+=("$r")
    done
  done

  # Ein zu loeschender Review-Report darf keinen lebenden Verweis mehr tragen:
  # dahinter stehen unter anderem nach AGENTS.md 3.4 eingefrorene ADRs, in
  # denen der Bruch nicht behebbar waere. Vor jeder Mutation pruefen.
  local -a haenger=()
  local rb treffer t
  for r in "${reviews[@]:-}"; do
    [ -n "$r" ] || continue
    rb="$(basename "$r")"
    treffer="$(git grep -l -F -e "$rb" -- ':!.harness/baseline' ':!docs/reviews' 2>/dev/null || true)"
    while IFS= read -r t; do
      [ -n "$t" ] || continue
      case " ${slices[*]} $plan " in *" $t "*) continue ;; esac
      haenger+=("$t -> $rb")
    done <<< "$treffer"
  done
  if [ "${#haenger[@]}" -gt 0 ]; then
    echo "archive-welle: ein Review-Report soll verschwinden, auf den noch verwiesen wird:" >&2
    printf '  %s\n' "${haenger[@]}" >&2
    echo "  Erst den Verweis aufloesen (oder die Referenz in .d-check.yml ausnehmen, mit ADR nach AGENTS.md 3.5), dann archivieren." >&2
    exit 3
  fi

  local tdir
  tdir="$(templates_dir)"

  echo "archive-welle: $WELLE"
  echo "  Mitglieder (Welle-Feld nennt $WELLE): ${#mitglieder[@]}"
  echo "  wellenlos (seit der letzten Closure): ${#wellenlose[@]}"
  echo "  fremd (andere Welle, bleibt liegen):  ${#fremde[@]}"
  echo "  Review-Reports (ohne Stub):           ${#reviews[@]}"

  # ---- Commit 1: reiner Move, kein Byte Inhalt (AGENTS.md 3.3) -------------
  mkdir -p "$ziel"
  for f in "${slices[@]}" "$plan"; do
    git mv "$f" "$ziel/$(basename "$f")"
  done
  git commit -q -m "archive-welle: $WELLE  Zeitdokumente nach done/$WELLE/ (reiner Move)"

  # ---- Commit 2: Archiv, Stubs, Verweis-Nachzug ----------------------------
  local -a archivpfade=()
  for f in "${slices[@]}" "$plan"; do archivpfade+=("$ziel/$(basename "$f")"); done
  for r in "${reviews[@]:-}"; do [ -n "$r" ] && archivpfade+=("$r"); done

  local image="${ARCHIVE_IMAGE:?archive-welle: ARCHIVE_IMAGE ist Pflicht (Makefile setzt es)}"
  docker run --rm --network none -v "$PWD":/repo:ro -w /repo --entrypoint git "$image" \
    -c safe.directory=/repo archive --format=zip HEAD -- "${archivpfade[@]}" > "$ziel/archiv.zip"

  local wdatum planbase
  wdatum="$(sed -n 's/^\*\*Abschluss:\*\*[[:space:]]*\([0-9-]\{10\}\).*/\1/p' "$results" | head -n 1)"
  wdatum="${wdatum:-—}"
  planbase="$(basename "$plan")"

  # Slice-Stubs. Der Welle-Zeiger bleibt ein Geschwister-Link: der Plan zieht
  # in dasselbe Verzeichnis mit.
  local base nummer titel wellefeld
  for f in "${slices[@]}"; do
    base="$(basename "$f")"
    nummer="$(slice_nummer "$base")"
    titel="$(titel_von "$ziel/$base")"
    if [ "$(klasse_von "$ziel/$base" "$WELLE")" = "mitglied" ]; then
      wellefeld="[$WELLE]($planbase)"
    else
      wellefeld="ohne Welle"
    fi
    stub_aus_vorlage \
      "$tdir/archiv-stub-slice.template.md" "$ziel/$base" "$WELLE" \
      "$ziel/archiv.zip" "$ziel/$base" \
      "s#<NNN>#$nummer#g" \
      "s#<Titel>#$(sed_ersatz "$titel")#g" \
      "s#<welle-id | ohne Welle>#$(sed_ersatz "$wellefeld")#g" \
      "s#<JJJJ-MM-TT>#$(geschlossen_datum "$ziel/$base" "$wdatum")#g" \
      "s#<BEO-\*, ADR-\*, Folge-Slice — oder .— keine —.>#$(sed_ersatz "$(feld_hervorgegangen "$ziel/$base" "$WELLE")")#g"
    stub_form_ok "$ziel/$base"
  done

  # Welle-Stub. Die Ergebnisnotiz bleibt flach, eine Ebene hoeher.
  stub_aus_vorlage \
    "$tdir/archiv-stub-welle.template.md" "$ziel/$planbase" "$WELLE" \
    "$ziel/archiv.zip" "$ziel/$planbase" \
    "s#<Titel>#$(sed_ersatz "$(titel_von "$ziel/$planbase")")#g" \
    "s#<JJJJ-MM-TT>#$wdatum#g" \
    "s#<welle-id>-results\.md#[$WELLE-results.md](../$WELLE-results.md)#g" \
    "s#<N Slices, M Reviews>#${#slices[@]} Slices, ${#reviews[@]} Reviews#g"
  stub_form_ok "$ziel/$planbase"

  if [ "${#reviews[@]}" -gt 0 ]; then
    git rm -q -- "${reviews[@]}"
  fi

  # ---- Verweis-Nachzug, beide Formen --------------------------------------
  local -a bewegte=()
  for f in "${slices[@]}" "$plan"; do bewegte+=("$(basename "$f")"); done

  local praefix_treffer=0 bare_treffer=0 rf n
  for base in "${bewegte[@]}"; do
    while IFS= read -r rf; do
      [ -n "$rf" ] || continue
      rewrite_incoming_in_file "$rf" "$base" "done" "done/$WELLE"
      praefix_treffer=$((praefix_treffer + 1))
    done < <(git grep -l -F -e "done/$base" -- ':!.harness/baseline' 2>/dev/null || true)

    # Geschwister-relativ: die Dateien, die flach in done/ liegen bleiben.
    for rf in "$DONE"/*.md; do
      [ -e "$rf" ] || continue
      n="$(rewrite_bare_sibling_in_file "$rf" "$base" "$WELLE/")"
      bare_treffer=$((bare_treffer + n))
    done
  done

  git add -A
  git commit -q -m "archive-welle: $WELLE  Archiv, Stubs und Verweis-Nachzug (Inhalt, getrennt vom Move — AGENTS.md §3.3)"

  echo "archive-welle ok: $WELLE"
  echo "  Commit 1 (reiner Move): ${#slices[@]} Slice(s) + Welle-Plan nach $ziel/"
  echo "  Commit 2 (Inhalt): archiv.zip ($(wc -c < "$ziel/archiv.zip") Bytes), $((${#slices[@]} + 1)) Stub(s), ${#reviews[@]} Review-Report(s) entfernt"
  echo "  Verweise: $praefix_treffer Datei(en) mit Praefix-Form, $bare_treffer geschwister-relative Ziel(e)"
  echo "  Naechster Schritt: make docs-check — er zeigt, was Grenze 2 und 3 (Skriptkopf) haben stehen lassen."
}

# BASH_SOURCE-Waechter: test/archive-welle.bats sourced dieses Skript, um die
# reinen Funktionen direkt zu pruefen, ohne main() (und damit git mv, docker
# und Commits) auszuloesen.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
