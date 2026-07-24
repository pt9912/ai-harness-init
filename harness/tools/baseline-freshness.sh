#!/usr/bin/env bash
# baseline-freshness — duenner Wrapper um component-freshness.sh (slice-040) fuer
# die Regelwerk-Tag-Achse: BASELINE_TAG vs. Kurs-releases/latest (slice-018,
# MR-007). Die Fetch/Vergleich-Mechanik lebt seit slice-040 EINMAL im generischen
# Sensor (kein dupliziertes fetch/compare); dieser Wrapper haelt nur die
# baseline-eigene Parametrierung (Name, Pin-Quelle BASELINE_TAG, Re-Baseline-Advice)
# und seine bestehende 2-arg `--compare <gepinnt> <latest>`-Schnittstelle — der
# test/baseline-freshness.bats haengt an genau dieser Schnittstelle.
#
# Ergaenzt regelwerk-check (Asset-Achse, slice-009): der prueft nur, ob das Asset
# des GEPINNTEN Tags nachtraeglich veraendert wurde — nicht, ob ein NEUER Tag
# erschien (MR-007, Auflösungs-Trigger). Zusammen ergeben beide das volle Bild.
#
# NETZ-Operation, NICHT in gates (LH-QA-01: make gates bleibt offline-gruen). Der
# Check MUTIERT nichts — ein Re-Baseline ist eine separate, bewusste MR-007-Operation.
# Exit-Codes unveraendert (0/1/2 = aktuell/veraltet/fetch-fehler).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERIC="$HERE/component-freshness.sh"
NAME="baseline-freshness"
ADVICE="Re-Baseline pruefen (MR-007): Baum neu vendoren + BASELINE_TAG/BASELINE_ZIP_SHA256 neu pinnen."

# 2-arg --compare (baseline-eigene Schnittstelle) -> 3-arg generisch, Name injiziert.
if [ "${1:-}" = "--compare" ]; then
  exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "${2:-}" "${3:-}"
fi

# Voller Lauf: gepinnt aus BASELINE_TAG (einzige Tag-Quelle, MR-007), latest per
# Netz — der generische Sensor macht Fetch + Vergleich.
pinned="${BASELINE_TAG:?BASELINE_TAG nicht gesetzt — via Makefile durchreichen}"
url="${RELEASES_LATEST_URL:?RELEASES_LATEST_URL nicht gesetzt — via Makefile durchreichen}"
exec env COMPONENT_NAME="$NAME" COMPONENT_PINNED="$pinned" \
  COMPONENT_ADVICE="$ADVICE" RELEASES_LATEST_URL="$url" bash "$GENERIC"
