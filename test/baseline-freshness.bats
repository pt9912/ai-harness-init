#!/usr/bin/env bats
# baseline-freshness.bats — Tests fuer den Freshness-Sensor
# (harness/tools/baseline-freshness.sh). Docker-only im gepinnten bats-Image
# (make test; slice-018 / MR-007 / LH-QA-01).
#
# HERMETISCH: getestet wird ausschliesslich der Vergleicher ueber `--compare
# <gepinnt> <latest>` mit Fixture-Strings. Der Fetch (Netz) ist im Skript davon
# getrennt und wird hier NIE aufgerufen — der Test trifft nie das Netz, sonst
# braeche `make test` (in gates) die offline-gruen-Zusage (LH-QA-01).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  FRESH="$REPO/harness/tools/baseline-freshness.sh"
}

run_compare() { run bash "$FRESH" --compare "$1" "$2"; }

@test "freshness: latest == gepinnt -> aktuell (exit 0)" {
  run_compare "v3.1.0" "v3.1.0"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'aktuell'
}

@test "freshness: neuerer Tag -> VERALTET/Alarm (exit 1)" {
  run_compare "v3.1.0" "v3.2.0"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'VERALTET'
  # Beide Tags werden genannt (gepinnt + latest), damit der Alarm handlungsleitend ist.
  printf '%s' "$output" | grep -q 'v3.1.0'
  printf '%s' "$output" | grep -q 'v3.2.0'
}

@test "freshness: leerer latest (Fetch-Fehler) -> eigener Exit 2, NICHT veraltet" {
  run_compare "v3.1.0" ""
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -q 'FETCH-FEHLER'
  # Fetch-Fehler darf NICHT als "veraltet" durchgehen (eigene Klasse, wie regelwerk-check).
  ! printf '%s' "$output" | grep -q 'VERALTET'
}
