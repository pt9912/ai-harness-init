#!/usr/bin/env bash
# component-freshness — parametrierter, read-only Freshness-Sensor: meldet, ob
# upstream einen NEUEREN Release-Tag als der gepinnte Wert einer Komponente
# fuehrt (GitHub releases/latest-Achse). Verallgemeinert die Mechanik, die
# baseline-freshness.sh (slice-018) fuer die Regelwerk-Tag-Achse einfuehrte, auf
# beliebige (name, pinned, releases-latest-url)-Tripel (slice-040, MR-007).
#
# NETZ-Operation, NICHT in gates (LH-QA-01: make gates bleibt offline-gruen). Der
# Sensor MUTIERT nichts — der Bump eines gemeldeten Drifts bleibt eine separate,
# bewusste Operation (MR-007 fuer die Baseline; der jeweilige Pin sonst).
#
# Mechanik ohne jq/API/JSON (LH-QA-03): dem Redirect von .../releases/latest
# folgen und die effektive URL lesen — sie endet auf /releases/tag/<latest>.
# curl -w '%{url_effective}' + basename, Vergleich gegen den gepinnten Wert.
#
# Exit (wie baseline-freshness/regelwerk-check): 0 = aktuell (latest == gepinnt),
# 1 = VERALTET (neuerer Tag, Alarm), 2 = Fetch-/Parse-Fehler (KEIN Veraltet-Urteil).
#
# Fetch<->Vergleich getrennt: `--compare <name> <gepinnt> <latest>` ruft NUR den
# Vergleicher (hermetisch, kein Netz) — so testet der bats-Test in gates die
# Semantik mit Fixture-Strings, ohne je das Netz zu treffen. bash + coreutils + curl.
set -euo pipefail

# Vergleicher (rein, netzlos): gepinnt vs. latest. Leerer latest = Fetch-Fehler.
# Der Name steht in JEDER Zeile: ein rotes Nachtlauf-Kaestchen soll sagen, WELCHE
# Komponente driftet, ohne dass man raten muss (das ist der Sinn der
# Parametrierung ueber baseline-freshness hinaus). COMPONENT_ADVICE (optional):
# eine handlungsleitende Zeile im VERALTET-Fall (je Achse verschieden).
compare_tags() {
  local name="$1" pinned="$2" latest="$3"
  if [ -z "$latest" ]; then
    echo "$name: FETCH-FEHLER (kein Freshness-Urteil): konnte den latest-Tag nicht bestimmen." >&2
    return 2
  fi
  if [ "$latest" = "$pinned" ]; then
    echo "$name: aktuell — gepinnt und latest sind beide $pinned."
    return 0
  fi
  echo "$name: VERALTET — upstream hat einen neueren Release-Tag als gepinnt."
  echo "  gepinnt: $pinned"
  echo "  latest:  $latest"
  if [ -n "${COMPONENT_ADVICE:-}" ]; then
    echo "  -> ${COMPONENT_ADVICE}"
  fi
  return 1
}

# Fetch (Netz): dem releases/latest-Redirect folgen, latest-Tag extrahieren.
# Bei curl-Fehler ODER unerwarteter effektiver URL: return 2 (kein leiser Fehler).
fetch_latest_tag() {
  local url="$1" effective
  effective="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$url")" || return 2
  case "$effective" in
    */releases/tag/*) basename "$effective" ;;
    *) return 2 ;;
  esac
}

# --compare <name> <gepinnt> <latest>: nur der Vergleicher (hermetisch, fuer den Test).
if [ "${1:-}" = "--compare" ]; then
  rc=0; compare_tags "${2:-}" "${3:-}" "${4:-}" || rc=$?
  exit "$rc"
fi

# Voller Lauf: name/pinned/url reicht der Aufrufer (Makefile-Target) via env durch
# (jede Achse benennt ihre kanonische Pin-Quelle im Makefile-Target).
name="${COMPONENT_NAME:?COMPONENT_NAME nicht gesetzt — via Makefile durchreichen}"
pinned="${COMPONENT_PINNED:?COMPONENT_PINNED nicht gesetzt — via Makefile durchreichen}"
url="${RELEASES_LATEST_URL:?RELEASES_LATEST_URL nicht gesetzt — via Makefile durchreichen}"
latest="$(fetch_latest_tag "$url")" || latest=""
rc=0; compare_tags "$name" "$pinned" "$latest" || rc=$?
exit "$rc"
