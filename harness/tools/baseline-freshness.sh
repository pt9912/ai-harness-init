#!/usr/bin/env bash
# baseline-freshness — read-only Sensor: meldet, ob upstream ein NEUERER Tag als
# BASELINE_TAG existiert (Release-LISTEN-Achse). Ergaenzt regelwerk-check
# (Asset-Achse, slice-009): der prueft nur, ob das Asset des GEPINNTEN Tags
# nachtraeglich veraendert wurde — nicht, ob ein NEUER Tag erschien (MR-007,
# Auflösungs-Trigger). Zusammen ergeben beide das volle Upstream-Bild.
#
# NETZ-Operation, NICHT in gates (LH-QA-01: make gates bleibt offline-gruen).
# Der Check MUTIERT nichts — ein Re-Baseline ist eine separate, bewusste
# MR-007-Operation (Baum neu vendoren + BASELINE_TAG/BASELINE_ZIP_SHA256 neu pinnen).
#
# Mechanik ohne jq/API/JSON (LH-QA-03): dem Redirect von .../releases/latest
# folgen und die effektive URL lesen — sie endet auf /releases/tag/<latest>.
# curl -w '%{url_effective}' + basename, Vergleich gegen BASELINE_TAG.
#
# Exit (spiegelt regelwerk-checks 0/1/2): 0 = aktuell (latest == gepinnt),
# 1 = VERALTET (neuerer Tag, Alarm), 2 = Fetch-/Parse-Fehler (KEIN Veraltet-Urteil).
#
# Fetch<->Vergleich getrennt: `--compare <gepinnt> <latest>` ruft NUR den
# Vergleicher (hermetisch, kein Netz) — so testet der bats-Test in gates die
# Semantik mit Fixture-Strings, ohne je das Netz zu treffen. Kein node/jq/python
# (LH-QA-03): bash + coreutils + curl.
set -euo pipefail

# Vergleicher (rein, netzlos): gepinnt vs. latest. Leerer latest = Fetch-Fehler.
compare_tags() {
  local pinned="$1" latest="$2"
  if [ -z "$latest" ]; then
    echo "FETCH-FEHLER (kein Freshness-Urteil): konnte den latest-Tag nicht bestimmen." >&2
    return 2
  fi
  if [ "$latest" = "$pinned" ]; then
    echo "baseline-freshness: aktuell — gepinnt und latest sind beide $pinned."
    return 0
  fi
  echo "VERALTET: upstream hat einen neueren Release-Tag als gepinnt."
  echo "  gepinnt: $pinned"
  echo "  latest:  $latest"
  echo "  -> Re-Baseline pruefen (MR-007): Baum neu vendoren + BASELINE_TAG/BASELINE_ZIP_SHA256 neu pinnen."
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

# --compare <gepinnt> <latest>: nur der Vergleicher (hermetisch, fuer den Test).
if [ "${1:-}" = "--compare" ]; then
  rc=0; compare_tags "${2:-}" "${3:-}" || rc=$?
  exit "$rc"
fi

# Voller Lauf: gepinnt aus BASELINE_TAG, latest per Netz — beide reicht das
# Makefile durch (einzige Tag-Quelle bleibt BASELINE_TAG, MR-007).
pinned="${BASELINE_TAG:?BASELINE_TAG nicht gesetzt — via Makefile durchreichen}"
url="${RELEASES_LATEST_URL:?RELEASES_LATEST_URL nicht gesetzt — via Makefile durchreichen}"
latest="$(fetch_latest_tag "$url")" || latest=""
rc=0; compare_tags "$pinned" "$latest" || rc=$?
exit "$rc"
