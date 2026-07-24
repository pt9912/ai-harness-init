#!/usr/bin/env bats
# component-freshness.bats — Tests fuer den generischen Freshness-Sensor
# (harness/tools/component-freshness.sh, slice-040 / MR-007 / LH-QA-01).
# Docker-only im gepinnten bats-Image (make test).
#
# HERMETISCH: getestet wird ausschliesslich der Vergleicher ueber
# `--compare <name> <gepinnt> <latest>` mit Fixture-Strings. Der Fetch (Netz) ist
# im Skript davon getrennt und wird hier NIE aufgerufen — der Test trifft nie das
# Netz, sonst braeche `make test` (in gates) die offline-gruen-Zusage (LH-QA-01).
#
# Die drei Exit-Klassen (aktuell/veraltet/fetch-fehler) sind je Achse dieselbe
# generische Semantik; zusaetzlich zur baseline-Achse (baseline-freshness.bats,
# Regressions-Wache ueber den Wrapper) deckt dieser Test die golangci-lint- und
# d-check-Achsen ab, die den generischen Sensor DIREKT nutzen. Die NEUE
# Eigenschaft gegenueber baseline-freshness: der Komponenten-Name steht im Output
# (ein rotes Kaestchen sagt, WELCHE Komponente driftet).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  FRESH="$REPO/harness/tools/component-freshness.sh"
}

run_compare() { run bash "$FRESH" --compare "$1" "$2" "$3"; }

@test "component-freshness: aktuell (latest == gepinnt -> exit 0, Name im Output)" {
  run_compare "golangci-lint" "v2.12.2" "v2.12.2"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'aktuell'
  # Name-Parametrierung: der Komponenten-Name steht in der Meldung.
  printf '%s' "$output" | grep -q 'golangci-lint'
}

@test "component-freshness: VERALTET (neuerer Tag -> exit 1, Name + beide Tags)" {
  run_compare "d-check" "v0.51.1" "v0.52.0"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'VERALTET'
  # Name + beide Tags werden genannt, damit der Alarm handlungsleitend ist.
  printf '%s' "$output" | grep -q 'd-check'
  printf '%s' "$output" | grep -q 'v0.51.1'
  printf '%s' "$output" | grep -q 'v0.52.0'
}

@test "component-freshness: FETCH-FEHLER (leerer latest -> exit 2, NICHT veraltet)" {
  run_compare "golangci-lint" "v2.12.2" ""
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -q 'FETCH-FEHLER'
  # Fetch-Fehler darf NICHT als "veraltet" durchgehen (eigene Klasse, wie regelwerk-check).
  ! printf '%s' "$output" | grep -q 'VERALTET'
}
