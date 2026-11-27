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
#   rest             — Dateien des Bauch-Walks ausserhalb jeder Tafel-Menge;
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
# ZUORDNUNGS-REST — Klassen, die kein Gate urteilt und die darum in keiner
# Menge liegen (LICENSE, root-Repo-Metadaten, .gitkeep, docs/user/images/, das
# Homebrew-Formular-Template, die zwei d-check-ignore-Referenzen, die
# extract-*.awk-Helper): `rest` nennt sie, und die Mischform gibt fail-closed
# nicht frei (MR-017) — der Fast-Pfad schrumpft mit der Tafel-Vereinigung
# (ADR-0108 Abwaegung E). Zuschlaege an eine Menge sind eine Plan-Entscheidung
# mit eigener Begruendung, kein stiller Eintrag.
set -euo pipefail

# MENGE_AUSSCHLUESS — siehe Kopf; jeder Eintrag traegt den ./-Praefix, der
# Match prefixed ./ vor den Pfad (beide Walk-Zweige liefern ./-freie Pfade).
MENGE_AUSSCHLUESS=(
    './.harness/stamp/**'   # ADR-0103: der Record-Konsum (.harness/stamp/mutate) rotiert keinen Key
    './.harness/state/**'   # die Key- und Gesamt-Ablage — ein Key deckt sich nicht selbst
    './.tmp/**'             # Arbeitsablage der Laeufe (.d-check.yml scan.ignore-Klasse), kein Artefakt
)

# tafel_menge <check> — die Tafel-Menge des Checks (ADR-0035 Festlegung 3,
# je Zeile der Form des Plans §3): Glob-Zeilen mit ./-Praefix; der Match-
# Kontext ist case-Glob, `*` durchquert Trenner, `./x/*` deckt x in jeder
# Tiefe. Ein Check ohne Zeilen ausserhalb des case-Zweigs ist unbekannt.
tafel_menge() {
  case "$1" in
    environment-check)
      # die SPEC-099-Zeile lebt in der Datei — die Menge deckt die Datei (nicht kleiner).
      printf '%s\n' \
        './harness/tools/environment-check.sh' \
        './harness/tools/environment-inventory.txt' \
        './spec/*.md'
        ;;
    baseline-verify)
      printf '%s\n' \
        './SHA256SUMS' \
        './.harness/baseline/*' \
        './internal/fetch/baseline.go'
        ;;
    docs-check-host)
      printf '%s\n' \
        './.d-check.yml' \
        './d-check.mk' \
        './*.md'
        ;;
    lint)
      printf '%s\n' \
        './.golangci.yml' \
        './Dockerfile' \
        './go.mod' \
        './go.sum' \
        './internal/*.go' \
        './cmd/*.go' \
        './internal/emit/templates/enforce/*.sh'
        ;;
    build)
      printf '%s\n' \
        './Dockerfile' \
        './go.mod' \
        './go.sum' \
        './internal/*.go' \
        './cmd/*.go'
        ;;
    test)
      printf '%s\n' \
        './Dockerfile' \
        './go.mod' \
        './go.sum' \
        './internal/*.go' \
        './cmd/*.go' \
        './test/*'
        ;;
    shell-lint)
      # .claude/settings.json und .codex/hooks.json sind Wächter-Verdrahtung,
      # die kein Check urteilt — sie liegen im deklarierten Zuordnungs-Rest.
      printf '%s\n' \
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
        './internal/*.go' \
        './cmd/*.go' \
        './harness/tools/*.sh' \
        './.claude/hooks/*.sh' \
        './.githooks/*'
        ;;
    register-ausgang)
      printf '%s\n' \
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
      printf '%s\n' \
        './Makefile' \
        './cmd/*.go'
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
# je Zeile `check\vGlob`. Der per-Paar-Präfix-Vergleich filtert auf den Check,
# der case-Glob urteilt über den Pfad — so lädt die Tafel einmal pro
# Aufruf statt je (Check × Datei) wieder neu.
PAARE_MENGE=()
PAARE_AUSSCHLUESS=()

tafel_laden() {
  local check v
  while IFS= read -r check; do
    [ -n "$check" ] || continue
    while IFS= read -r v; do
      [ -n "$v" ] || continue
      PAARE_MENGE+=("${check}"$'\v'"${v}")
    done < <(tafel_menge "$check")
    while IFS= read -r v; do
      [ -n "$v" ] || continue
      PAARE_AUSSCHLUESS+=("${check}"$'\v'"${v}")
    done < <(tafel_ausschluss "$check")
  done < <(kante)
}

ist_ausgeschlossen() {
  local e
  for e in "${MENGE_AUSSCHLUESS[@]}"; do
    case "./$1" in $e) return 0 ;; esac
  done
  return 1
}

in_menge() {
  local check="$1" f="./$2" e p
  for e in "${PAARE_AUSSCHLUESS[@]}"; do
    [ "${e%%$'\v'*}" = "$check" ] || continue
    p="${e#*$'\v'}"
    case "$f" in $p) return 1 ;; esac
  done
  for e in "${PAARE_MENGE[@]}"; do
    [ "${e%%$'\v'*}" = "$check" ] || continue
    p="${e#*$'\v'}"
    case "$f" in $p) return 0 ;; esac
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
    # Exit 1 (die Mischform entzieht der Alternative die Basis, MR-017).
    rest_zeilen=""
    for f in "${DATEIEN[@]}"; do
      ist_ausgeschlossen "$f" && continue
      for e in "${PAARE_MENGE[@]}"; do
        p="${e#*$'\v'}"
        case "./$f" in $p) continue 2 ;; esac
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