#!/usr/bin/env bash
# gates-keys — Satzerzeuger der je-Check-Pruefgegenstands-Schluessel (ADR-0108,
# Plan slice-gates-pruefgegenstand-stempel-v1 §3). EINE Definition je
# Bezugsmenge, drei Leser (Schreiber `record-gates alle`, Fast-Pfad
# `gates-fast liste/key/stamp`, Stop-Hook `liste/key/rest`). Modi:
#   liste            — die Kante `record-gates: <checks>` des Makefile, zeilenweise
#   key <check>      — der Inhalt-Hash der Tafel-Menge des Checks, 64 Hex
#   menge <check>    — die Dateien der Tafel-Menge des Checks, zeilenweise
#   stamp <checks…>  — je Check den Key nach .harness/state/gates-passed-<check>.key
#   alle             — `stamp` ueber der ganzen Kante (der Schreiber bleibt
#                      `record-gates`; dieser Modus ist sein Rezept-Aufruf)
#   rest             — Dateien des Bauch-Walks ausserhalb jeder Tafel-Menge UND
#                      jeder deklarierten Rest-Klasse (MENGE_REST unten);
#                      Exit 0 leer, sonst Liste und Exit 1 (fail-closed, MR-017)
# Hermetisch: `--wurzel <dir>` loest die Wurzel auf, wenn kein git faehrt
# (gepinntes bats-Image, Fixture); ohne `--wurzel` gilt das git-Toplevel, und
# ohne git der Lauf ueber `find`.
#
# FAIL-CLOSED: unbekannter Check, leere Menge, leere Kante oder leere Walk
# enden mit Exit != 0 und geben Nirgends frei (MR-017); `key` und `menge`
# nennen einen unbekannten Check mit der Zeile "unbekannter Check" auf stderr.
# Die Walk-Zeilen-Form ist die von working-tree-hash.sh (getrackt +
# untracked, ignore-standard; hermetisch `find` statt git), die Zeilen-Form der
# Keys dieselbe (sha256sum/LINK/GONE, sortiert); ein leeres Byte-Sheet ist kein
# Key — `key` endet rot statt einen leeren Key zu stempeln.
#
# MENGE_AUSSCHLUESS ist die eine Ausnahme-Definition, die jeder Walk und `rest`
# gelten (ADR-0103 Festlegung 2-Form): die Record-Ablage `.harness/stamp/**`
# (der Record-Konsum rotiert keinen Key), die Key-Ablage `.harness/state/**`
# (ein Key deckt sich nicht selbst) und die Lauf-Arbeitsablage `.tmp/**`
# (scan.ignore-Klasse, kein Artefakt). Waechst diese Liste, ist DAS der
# sichtbare Ort; jeder weitere Eintrag traegt seine Begruendung am Eintrag.
#
# ZUORDNUNGS-REST — je ADR-0108 Abwaegung E zwei Formen. *Aufnahme-Form:* Dateien,
# deren Lesung durch einen Check gezeigt ist, liegen in dessen Menge — `test` liest
# die Vorlagen (`go:embed all:templates/enforce|agents|commands`, Golden-Tests in
# internal/emit) und die emit-Testdata-Datei: beide Baumaenge liegen in der
# `test`-Menge (Eintraege im case-Zweig tafel_menge). *Deklarations-Form*
# (ADR-0035 Festlegung 3, deklarierte Ausnahme obenauf einer Definition): Dateien,
# ueber die kein Check der Kante urteilt, liegen in MENGE_REST unterhalb — je
# Klasse-Glob einer Zeile mit genanntem Grund am Eintrag, als Rest gezaehlt statt als
# Deckung; `rest` liest sie als Rest mit (Exit 0), Inhalt ausserhalb jeder Menge UND
# dieser Liste bleibt der fail-closed Gap-Detektor (Liste und Exit 1, MR-017).
# Zuschlaege an eine Menge und Eintraege in MENGE_REST sind eine Plan-Entscheidung
# mit eigener Begruendung, kein stiller Eintrag (Plan slice-stamp-records-konsum-v1
# §3, Mess-Beleg: der Stop-Hook-Mischform-Zug — approve an der deklarierten Form).
#
# MESSREZEPT JE CHECK (Plan slice-gates-pruefgegenstand-stempel-v1 §3): je
# Tafel-Zeile die Lesung am realen Rezept — was der Check liest, dass die
# Menge es deckt, und der Rest, den kein baum-abgeleiteter Schluessel traegt.
# Das Messrezept benennt den Rest je Zeile, schliesst ihn nicht; deckt die
# Menge den gelesenen Bestand eines Checks nicht, faehrt der Check voll
# (Plan §6, Ausgang: deklarierter Bestand). Die Glob-Lesung deckt jede Tiefe
# (glob_zu_regex: `*` durchlaeuft Trenner); die Walk-Zeilen sind ./-frei.
#   environment-check:  liest das Rezept (Makefile), sein Skript, das Inventar
#                       und die SPEC-099-Zeile
#                       in spec/spezifikation.md — ./spec/*.md deckt die Datei.
#   docs-check-host:    liest das Rezept (Makefile), .d-check.yml, d-check.mk
#                       und alle .md des Pruefbereichs vermindert um die
#                       scan.ignore-Ausschluesse (tafel_ausschluss); Rest: der
#                       d-check-Traeger (Zustands-Ablage, kein Walk-Artefakt).
#   baseline-verify:    liest das Rezept (Makefile), sein Skript und den
#                       vendored Baum inkl. SHA256SUMS im Tag-Verzeichnis (am
#                       Wurzelpfad liegt keine — der Eintrag dort entfaellt);
#                       die Pin-Kopplung bleibt konservativ, sie ist lauf-fern.
#   lint, build, test:  lesen das Rezept (Makefile), die Go-Quellen und go.mod
#                       am Host-Weg — go.sum liegt im Bestand nicht (kein
#                       Eintrag); Dockerfile bleibt als Image-Weg-Kopplung,
#                       .dockerignore traegt docker vor beiden Stufen in den
#                       Kontext (lint, build); der test-Check liest dazu die
#                       Vorlagen-Baume der //go:embed-Direktiven und die
#                       emit-Testdata-Datei (Zuschlag je Plan
#                       slice-stamp-records-konsum-v1 §3);
#                       Rest: die Go-Toolchain- und bats-Fassung (Host-Werkzeug,
#                       ADR-0108 Festlegung 4).
#   shell-lint:         liest das Rezept (Makefile) und genau die
#                       Rezept-Listen (shellcheck ueber die vier Quell-Baeume
#                       plus .githooks, bats-lint ueber test/*.bats);
#                       .claude/settings.json und .codex/hooks.json liegen im
#                       Zuordnungs-Rest (Waechter-Verdrahtung, kein Check
#                       urteilt).
#   ci-lint:            actionlint liest .github/** (jede Tiefe, Workflows und
#                       lokale Actions); der Makefile-Eintrag koppelt die
#                       Pin-Stelle.
#   comment-claims:     liest das Rezept (Makefile) und genau die
#                       ls-files-Listen des Rezepts (Go ohne _test.go — derselbe
#                       Ausschluss in tafel_ausschluss).
#   register-ausgang:   liest das Rezept (Makefile), sein Skript und das
#                       Register unter observations.
#   mutate-greift:      liest den Treiber, die Fall-Skripte und das Rezept
#                       (Makefile); test/fixtures konservativ.
#   host-bin:           go build kompiliert die cmd-Quellen samt ihrer
#                       internal-Abhaengigkeiten und liest die Modul-Daten
#                       (go.mod; go.sum liegt im Bestand nicht — kein Eintrag);
#                       Rest: die Plattform-Auswertung
#                       (uname) und die Versions-Aufloesung (git).
#   span-check:         liest sein Skript, das Rezept (Traeger-Pfad) und die
#                       Deklaration der Verdrahtungssaetze in
#                       spec/spezifikation.md §5 — ./spec/*.md deckt die
#                       Datei; Rest: der gebaute Traeger (Zustands-Ablage,
#                       benutzt, nicht gemessen).
set -euo pipefail

# MENGE_AUSSCHLUESS — siehe Kopf; jeder Eintrag traegt den ./-Praefix, der
# Match prefixed ./ vor den Pfad (beide Walk-Zweige liefern ./-freie Pfade).
MENGE_AUSSCHLUESS=(
    './.harness/stamp/**'   # ADR-0103: der Record-Konsum (.harness/stamp/mutate) rotiert keinen Key
    './.harness/state/**'   # die Key- und Gesamt-Ablage — ein Key deckt sich nicht selbst
    './.tmp/**'             # Arbeitsablage der Laeufe (.d-check.yml scan.ignore-Klasse), kein Artefakt
)
MENGE_AUSSCHLUESS_RE=()

# MENGE_REST — der deklarierte Zuordnungs-Rest (siehe Kopf): je Klasse-Glob einer
# Zeile mit genanntem Grund am Eintrag (ADR-0035 Festlegung 3-Form). Wächst diese
# Liste, ist DAS der sichtbare Ort; ein Eintrag, dessen Check-Lesung je später
# gezeigt wird, wandert in die Menge und aus ihr heraus.
MENGE_REST=(
    './.claude/settings.json'  # Wächter-Verdrahtung (PreToolUse-Guard): kein Check der Kante urteilt
    './.codex/hooks.json'      # Wächter-Verdrahtung (SessionStart-Injektor): kein Check urteilt
    './.gitattributes'         # VCS-Werkgabe (Zeilenenden-Normalisierung): kein Check urteilt
    './.gitignore'             # Walk-Semantik: kein Check urteilt
    './.viper.sh'              # Werkzeug-Anschaffung des Inventars: kein Check urteilt
    './LICENSE'                # Lizenztext: kein Check urteilt
    './*.gitkeep'              # Platzhalter leerer Lifecycle-Verzeichnisse: kein Check urteilt
    './docs/user/images/*'     # Bilder der Operations-Doku (der Scan liest .md): kein Check urteilt
    './harness/tools/*.awk'    # Erfassungs-Helper (smoke und SessionStart-Hook, kein Gate der Kante): kein Check urteilt
    './harness/tools/homebrew-formula.rb.tmpl'  # Release-Formular (tap-nachzug, kein Gate der Kante): kein Check urteilt
)
MENGE_REST_RE=()

# glob_zu_regex — die Glob-Zeile der Mengen als ERE: `*` -> `.*`, `?` -> `.`
# (beide durchqueren Trenner, wie der Muster-Kontext sie liest — `./x/*` deckt
# x in jeder Tiefe); jedes uebrige Regex-Metazeichen bleibt literal. Der
# Aufrufer haengt Zeilen-Anfang und -Ende an. Die Deklaration bleibt in der
# Glob-Form des Plans §3; diese Lesung ist die EINE. Grenze: eine Zeichenklasse
# `[...]` liest diese Lesung literal, der case-Glob waere sie als Klasse — die
# Tafel fuehrt keine; eine kuenftige Classe-Eintraege braucht eine erweiterte
# Lesung, nicht eine still anders gelesene.
glob_zu_regex() {
  local roh="$1" zeichen era=""
  local metas="\\.[{]^\$()+|}"
  while [ -n "$roh" ]; do
    zeichen="${roh:0:1}"
    case "$zeichen" in
      '*') era="${era}.*" ;;
      '?') era="${era}." ;;
      *) if [ "${metas#*"$zeichen"}" != "$metas" ]; then
           era="${era}\\${zeichen}"
         else
           era="${era}${zeichen}"
         fi ;;
    esac
    roh="${roh:1}"
  done
  printf '%s\n' "$era"
}

# tafel_menge <check> — die Tafel-Menge des Checks (ADR-0035 Festlegung 3,
# je Zeile der Form des Plans §3): Glob-Zeilen mit ./-Praefix. Ein Check ohne
# Zeilen ausserhalb des case-Zweigs ist unbekannt.
tafel_menge() {
  case "$1" in
    environment-check)
      # die SPEC-099-Zeile lebt in der Datei — die Menge deckt die Datei (nicht kleiner).
      printf '%s\n' \
        './Makefile' \
        './harness/tools/environment-check.sh' \
        './harness/tools/environment-inventory.txt' \
        './spec/*.md'
        ;;
    baseline-verify)
      # das eigene Werkzeug-Skript liest der Lauf ein — ohne den Eintrag SKIPpt
      # der Fast-Pfad am Skript-Drift; die SHA256SUMS-Stelle lebt im
      # Tag-Verzeichnis (der Baum-Glob deckt sie, am Wurzelpfad liegt keine).
      printf '%s\n' \
        './Makefile' \
        './harness/tools/baseline-verify.sh' \
        './.harness/baseline/*' \
        './internal/fetch/baseline.go'
        ;;
    docs-check-host)
      printf '%s\n' \
        './Makefile' \
        './.d-check.yml' \
        './d-check.mk' \
        './*.md'
        ;;
    lint)
      printf '%s\n' \
        './Makefile' \
        './.golangci.yml' \
        './Dockerfile' \
        './.dockerignore' \
        './go.mod' \
        './internal/*.go' \
        './cmd/*.go' \
        './internal/emit/templates/enforce/*.sh'
        ;;
    build)
      printf '%s\n' \
        './Makefile' \
        './Dockerfile' \
        './.dockerignore' \
        './go.mod' \
        './internal/*.go' \
        './cmd/*.go'
        ;;
    test)
      # go:embed all:templates/… liest die Vorlagen beim Kompilieren der
      # Test-Pakete und die emit-Golden-Tests lesen den Vorlagen-Baum; eine
      # veraenderte oder geloeschte Vorlage erreicht zuerst diesen Check
      # (deletion bricht am Kompilieren der mitkompilieren Tests). lint und
      # build urteilen ueber Vorlagen-Inhalt nicht (Daten, kein Code).
      printf '%s\n' \
        './Makefile' \
        './Dockerfile' \
        './go.mod' \
        './internal/*.go' \
        './cmd/*.go' \
        './test/*' \
        './internal/emit/templates/*' \
        './internal/emit/testdata/*'
        ;;
    shell-lint)
      # .claude/settings.json und .codex/hooks.json sind Wächter-Verdrahtung,
      # die kein Check urteilt — sie liegen im deklarierten Zuordnungs-Rest.
      printf '%s\n' \
        './Makefile' \
        './.claude/hooks/*.sh' \
        './.githooks/*' \
        './harness/tools/*.sh' \
        './internal/emit/templates/*.sh' \
        './internal/emit/templates/enforce/*.sh' \
        './test/mutations/*.sh' \
        './test/*.bats'
        ;;
    ci-lint)
      printf '%s\n' \
        './.github/*' \
        './Makefile'
        ;;
    comment-claims)
      printf '%s\n' \
        './Makefile' \
        './internal/*.go' \
        './cmd/*.go' \
        './harness/tools/*.sh' \
        './.claude/hooks/*.sh' \
        './.githooks/*'
        ;;
    register-ausgang)
      printf '%s\n' \
        './Makefile' \
        './harness/tools/register-ausgang.sh' \
        './docs/plan/planning/observations/*'
        ;;
    mutate-greift)
      printf '%s\n' \
        './Makefile' \
        './harness/tools/mutate.sh' \
        './test/mutations/*' \
        './test/fixtures/*'
        ;;
    host-bin)
      # go build kompiliert die cmd-Quellen samt internal-Abhaengigkeiten und
      # liest die Modul-Daten (go.mod; go.sum liegt im Bestand nicht und der
      # Eintrag entfaellt hier je Form der Menge) — ohne den Eintrag SKIPpt der
      # Fast-Pfad am Bau-Drift, ohne den Bau zu fahren (Rezept-Form, nicht
      # Traeger-Inhalt).
      printf '%s\n' \
        './Makefile' \
        './go.mod' \
        './cmd/*.go' \
        './internal/*.go'
        ;;
    span-check)
      printf '%s\n' \
        './Makefile' \
        './harness/tools/span-check.sh' \
        './spec/*.md'
        ;;
    *)
      printf 'unbekannter Check: %s\n' "$1" >&2
      return 1
      ;;
  esac
}

# tafel_ausschluss <check> — die per-Check Schmaelerung derselben Menge
# (docs-check vermindert um die scan.ignore-Referenzen; comment-claims um die
# Tests, die der Sensor nicht scannt). Leere Ausgabe = keine Schmaelerung.
tafel_ausschluss() {
  case "$1" in
    docs-check-host)
      printf '%s\n' \
        './.harness/baseline/*' \
        './docs/user/claude-hooks-referenz.md' \
        './docs/plan/adr/0013-technik-stratum-als-zielort.md'
        ;;
    comment-claims)
      printf '%s\n' './*_test.go'
      ;;
  esac
}

# kante — die Ordnungskante aus dem Makefile; leer oder unlesbar ist ein
# Satzerzeuger-Fehler (fail-closed, MR-017).
kante() {
  local kante
  kante="$(sed -n 's/^record-gates:[[:space:]]*//p' Makefile | sed 's/##.*//' | tr -s '[:blank:]' '\n' | sed '/^$/d')" || {
    printf 'gates-keys: die Kante ist unlesbar (Makefile record-gates:)\n' >&2
    return 1
  }
  if [ -z "$kante" ]; then
    printf 'gates-keys: die Kante ist leer (Makefile record-gates:)\n' >&2
    return 1
  fi
  printf '%s\n' "$kante"
}

# Der einmal geladene Tafel-Bestand: PAARE_MENGE / PAARE_AUSSCHLUESS führen
# je Zeile `check\vERE` (die Glob-Zeile der Tafel, von glob_zu_regex gelesen).
# Der per-Paar-Präfix-Vergleich filtert auf den Check, der Glob urteilt über
# den Pfad — so lädt die Tafel einmal pro Aufruf statt je (Check × Datei)
# wieder neu.
PAARE_MENGE=()
PAARE_AUSSCHLUESS=()

# die Ausschluss-Zeilen des Kopf-Ausschlusses in derselben Lesung
for e1 in "${MENGE_AUSSCHLUESS[@]}"; do
  MENGE_AUSSCHLUESS_RE+=("$(glob_zu_regex "$e1")")
done
unset e1

# die deklarierten Rest-Klassen in derselben Lesung
for e1 in "${MENGE_REST[@]}"; do
  MENGE_REST_RE+=("$(glob_zu_regex "$e1")")
done
unset e1

# ist_rest_zeile — 0, wenn der Pfad in einer deklarierten Rest-Klasse liegt (siehe
# Kopf): `rest` liest sie als Rest mit, sonst nichts.
ist_rest_zeile() {
  local p="./$1" e
  for e in "${MENGE_REST_RE[@]}"; do
    [[ "$p" =~ ^($e)$ ]] && return 0
  done
  return 1
}

tafel_laden() {
  local check v
  while IFS= read -r check; do
    [ -n "$check" ] || continue
    while IFS= read -r v; do
      [ -n "$v" ] || continue
      PAARE_MENGE+=("${check}"$'\v'"$(glob_zu_regex "$v")")
    done < <(tafel_menge "$check")
    while IFS= read -r v; do
      [ -n "$v" ] || continue
      PAARE_AUSSCHLUESS+=("${check}"$'\v'"$(glob_zu_regex "$v")")
    done < <(tafel_ausschluss "$check")
  done < <(kante)
}

ist_ausgeschlossen() {
  local e
  for e in "${MENGE_AUSSCHLUESS_RE[@]}"; do
    [[ "./$1" =~ ^($e)$ ]] && return 0
  done
  return 1
}

in_menge() {
  local check="$1" f="./$2" e p
  for e in "${PAARE_AUSSCHLUESS[@]}"; do
    [ "${e%%$'\v'*}" = "$check" ] || continue
    p="${e#*$'\v'}"
    [[ "$f" =~ ^($p)$ ]] && return 1
  done
  for e in "${PAARE_MENGE[@]}"; do
    [ "${e%%$'\v'*}" = "$check" ] || continue
    p="${e#*$'\v'}"
    [[ "$f" =~ ^($p)$ ]] && return 0
  done
  return 1
}

# baum_laden — der Bauch-Walk in DATEIEN (./-freie, C-sortierte Zeilenform).
# Git-Zweig: getrackt + untracked, ignore-standard (Form working-tree-hash.sh);
# hermetische-Form (kein git, Fixture/im gepinntes bats-Image): `find` mit
# .git-Abstech. Beide liefern dieselbe Form; beide gelten MENGE_AUSSCHLUESS.
baum_laden() {
  DATEIEN=()
  local top
  if top="$(git -C "$WURZEL" rev-parse --show-toplevel 2>/dev/null)" \
     && [ "$top" = "$(cd "$WURZEL" && pwd)" ]; then
    mapfile -t DATEIEN < <(git -C "$WURZEL" ls-files --cached --others --exclude-standard | LC_ALL=C sort)
  else
    mapfile -t DATEIEN < <(
      (
        cd "$WURZEL"
        find . -name .git -prune -o \( -type f -o -type l \) -print
      ) | sed 's|^\./||' | LC_ALL=C sort
    )
  fi
  if [ "${#DATEIEN[@]}" -eq 0 ]; then
    printf 'gates-keys: der Bauch-Walk ist leer\n' >&2
    return 1
  fi
}

# check_bekannt <check> — ein Check ohne Menge-Zeilen ist unbekannt
# (fail-closed, MR-017).
check_bekannt() {
  local e
  for e in "${PAARE_MENGE[@]}"; do
    [ "${e%%$'\v'*}" = "$1" ] && return 0
  done
  printf 'unbekannter Check: %s\n' "$1" >&2
  return 1
}

# schluessel_form <check> — die Zeilen der Tafel-Menge des Checks (dieselbe
# Form wie working-tree-hash.sh): je Datei `sha256sum …  <pfad>`, Links als
# LINK-Zeile und fehlende Dateien als GONE-Zeile. Die regulaeren Dateien
# laufen in einem sha256sum-Aufruf — die Ausgabeform identisch.
schluessel_form() {
  local check="$1" f
  local datei=()
  for f in "${DATEIEN[@]}"; do
    ist_ausgeschlossen "$f" && continue
    in_menge "$check" "$f" || continue
    if [ -L "$f" ]; then
      printf 'LINK %s -> %s\n' "$f" "$(readlink -- "$f")"
    elif [ -f "$f" ]; then
      datei+=("$f")
    else
      printf 'GONE %s\n' "$f"
    fi
  done
  if [ "${#datei[@]}" -gt 0 ]; then
    sha256sum -- "${datei[@]}"
  fi
}

# stamp_check <check> — schreibt den Key des Checks; die zwei Gesamt-Dateien
# schreibt dieses Skript nie (die traegt allein record-gates, ADR-0108
# Festlegung 2).
stamp_check() {
  local check="$1" form wert
  check_bekannt "$check" || return 1
  form="$(schluessel_form "$check")"
  if [ -z "$form" ]; then
    printf 'gates-keys: leere Menge fuer %s — kein Key (fail-closed, MR-017)\n' "$check" >&2
    return 1
  fi
  wert="$(printf '%s\n' "$form" | sha256sum | awk '{print $1}')"
  mkdir -p .harness/state
  printf '%s\n' "$wert" > ".harness/state/gates-passed-${check}.key"
}

# Haupt — die Wurzel loesen, Tafel und Walk laden, den Modus fahren.
WURZEL=""
MODES=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --wurzel)
      if [ "$#" -lt 2 ]; then
        printf 'gates-keys: --wurzel braucht einen Pfad\n' >&2
        exit 2
      fi
      WURZEL="$2"
      shift 2
      ;;
    --wurzel=*)
      WURZEL="${1#--wurzel=}"
      shift
      ;;
    *)
      MODES+=("$1")
      shift
      ;;
  esac
done
if [ "${#MODES[@]}" -eq 0 ]; then
  printf 'gates-keys: Modus fehlt (liste | key <check> | menge <check> | stamp <checks…> | alle | rest)\n' >&2
  exit 2
fi

if [ -z "$WURZEL" ]; then
  if WURZEL="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
  else
    WURZEL="$PWD"
  fi
fi
cd "$WURZEL"

mode="${MODES[0]}"
shift_array=("${MODES[@]:1}")

# `liste` braucht Tafel und Walk nicht; jeder Modus mit Check-Bezug braucht jeden.
case "$mode" in
  liste)
    kante
    exit 0
    ;;
esac

baum_laden
tafel_laden
case "$mode" in
  key)
    if [ "${#shift_array[@]}" -ne 1 ]; then
      printf 'gates-keys: key braucht genau einen Check\n' >&2
      exit 2
    fi
    check_bekannt "${shift_array[0]}" || exit 1
    form="$(schluessel_form "${shift_array[0]}")"
    if [ -z "$form" ]; then
      printf 'gates-keys: leere Menge fuer %s — kein Key (fail-closed, MR-017)\n' "${shift_array[0]}" >&2
      exit 1
    fi
    printf '%s\n' "$form" | sha256sum | awk '{print $1}'
    ;;
  menge)
    if [ "${#shift_array[@]}" -ne 1 ]; then
      printf 'gates-keys: menge braucht genau einen Check\n' >&2
      exit 2
    fi
    check_bekannt "${shift_array[0]}" || exit 1
    check="${shift_array[0]}"
    for f in "${DATEIEN[@]}"; do
      ist_ausgeschlossen "$f" && continue
      if in_menge "$check" "$f"; then
        printf '%s\n' "$f"
      fi
    done
    ;;
  stamp)
    if [ "${#shift_array[@]}" -eq 0 ]; then
      printf 'gates-keys: stamp braucht mindestens einen Check\n' >&2
      exit 2
    fi
    for check in "${shift_array[@]}"; do
      stamp_check "$check"
    done
    ;;
  alle)
    while IFS= read -r check; do
      [ -n "$check" ] || continue
      stamp_check "$check"
    done < <(kante)
    ;;
  rest)
    # Der Bauch ausserhalb jeder Tafel-Menge: leer → Exit 0, sonst Liste und
    # Exit 1 (die Mischform entzieht der Alternative die Basis, MR-017). Die
    # Ablage-Ausschluesse und der deklarierte Zuordnungs-Rest (beide im Kopf
    # je Eintrag mit Grund) bleiben aus.
    rest_zeilen=""
    for f in "${DATEIEN[@]}"; do
      ist_ausgeschlossen "$f" && continue
      ist_rest_zeile "$f" && continue
      for e in "${PAARE_MENGE[@]}"; do
        p="${e#*$'\v'}"
        [[ "./$f" =~ ^($p)$ ]] && continue 2
      done
      rest_zeilen="${rest_zeilen}${f}"$'\n'
    done
    if [ -n "$rest_zeilen" ]; then
      printf '%s' "$rest_zeilen"
      exit 1
    fi
    ;;
  *)
    printf 'gates-keys: unbekannter Modus: %s\n' "$mode" >&2
    exit 2
    ;;
esac