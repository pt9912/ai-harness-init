#!/usr/bin/env bats
# go-freshness.bats — Tests fuer die Go-Toolchain-Freshness-Achse
# (harness/tools/go-freshness.sh, slice-041 / MR-007 / LH-QA-01).
# Docker-only im gepinnten bats-Image (make test).
#
# HERMETISCH: getestet werden ausschliesslich der `--normalize <roh>`-Pfad
# (Fixture-Strings) und der `--compare`-Pfad (der an den quellen-agnostischen
# Vergleicher aus component-freshness.sh delegiert). Der Fetch (go.dev, Netz) ist
# davon getrennt und wird hier NIE aufgerufen — sonst braeche `make test` (in
# gates) die offline-gruen-Zusage (LH-QA-01).
#
# Die NEUE Logik gegenueber slice-040 ist die NORMALISIERUNG (go.dev sagt
# `go1.26.5`, der Pin ist bar `1.26.4`); der Vergleich selbst ist wiederverwendet.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  GO_FRESH="$REPO/harness/tools/go-freshness.sh"
}

@test "go-freshness: normalize strippt go-Praefix + nimmt erste Zeile" {
  # Rohe go.dev-Ausgabe: `go1.26.5` gefolgt von einer time-Zeile.
  run bash "$GO_FRESH" --normalize $'go1.26.5\ntime 2026-07-01T21:24:27Z'
  [ "$status" -eq 0 ]
  [ "$output" = "1.26.5" ]
}

@test "go-freshness: normalize eines nackten go-Tags" {
  run bash "$GO_FRESH" --normalize "go1.26.4"
  [ "$status" -eq 0 ]
  [ "$output" = "1.26.4" ]
}

@test "go-freshness: normalize von leer bleibt leer (-> Fetch-Fehler-Klasse)" {
  run bash "$GO_FRESH" --normalize ""
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "go-freshness: compare aktuell (gepinnt == latest -> exit 0)" {
  run bash "$GO_FRESH" --compare "1.26.4" "1.26.4"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'aktuell'
  printf '%s' "$output" | grep -q 'go-toolchain'
}

@test "go-freshness: compare VERALTET (neuere Go-Version -> exit 1, beide genannt)" {
  run bash "$GO_FRESH" --compare "1.26.4" "1.26.5"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'VERALTET'
  printf '%s' "$output" | grep -q '1.26.4'
  printf '%s' "$output" | grep -q '1.26.5'
}

@test "go-freshness: compare leerer latest -> Fetch-Fehler (exit 2, NICHT veraltet)" {
  run bash "$GO_FRESH" --compare "1.26.4" ""
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -q 'FETCH-FEHLER'
  ! printf '%s' "$output" | grep -q 'VERALTET'
}

@test "go-freshness: normalize speist compare (Integration, offline)" {
  # Der reale Fluss ohne Netz: rohe go.dev-Form normalisieren, dann vergleichen.
  # Gepinnt == normalisiertes latest -> aktuell. Bricht die Normalisierung (z. B.
  # go-Praefix bleibt), stimmt der Vergleich nicht mehr -> dieser Test faellt.
  latest="$(bash "$GO_FRESH" --normalize $'go1.26.4\ntime x')"
  run bash "$GO_FRESH" --compare "1.26.4" "$latest"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'aktuell'
}
