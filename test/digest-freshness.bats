#!/usr/bin/env bats
# digest-freshness.bats — Tests fuer die Digest-Achse (harness/tools/digest-freshness.sh,
# LH-QA-02 · seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor).
# Docker-only im gepinnten bats-Image (make test).
#
# HERMETISCH: getestet werden `--compare` (Fixture-Strings) und `--pins`, das die REALEN
# Pin-Stellen liest (Makefile, Dockerfile, d-check.mk, internal/emit). Die Aufloesung gegen
# die Registry (Netz) wird hier NIE aufgerufen — sonst braeche `make test` (in gates) die
# offline-gruen-Zusage (LH-QA-01). Dass ein falscher Digest den Lauf rot faerbt, haelt dieser
# Test nur fuer den Vergleicher; der Lauf gegen die Registry ist `make freshness-digest`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DF="$REPO/harness/tools/digest-freshness.sh"
  A="sha256:$(printf 'a%.0s' $(seq 64))"
  B="sha256:$(printf 'b%.0s' $(seq 64))"
}

@test "digest-freshness: compare gleich -> exit 0" {
  run bash "$DF" --compare go-toolchain golang:1.27.2 "$A" "$A"
  [ "$status" -eq 0 ]
  [[ "$output" == *"aktuell"* ]]
}

@test "digest-freshness: compare ungleich -> exit 1, nennt Tag, beide Digests und die Stelle" {
  run bash "$DF" --compare go-toolchain golang:1.27.2 "$A" "$B" "Dockerfile FROM golang"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DIGEST WEICHT AB"* ]]
  [[ "$output" == *"golang:1.27.2"* ]]
  [[ "$output" == *"$A"* ]]
  [[ "$output" == *"$B"* ]]
  [[ "$output" == *"Dockerfile FROM golang"* ]]
}

@test "digest-freshness: compare mit leerer Aufloesung -> exit 2 (kein Urteil)" {
  run bash "$DF" --compare go-toolchain golang:1.27.2 "$A" ""
  [ "$status" -eq 2 ]
  [[ "$output" == *"FETCH-FEHLER"* ]]
}

@test "digest-freshness: --pins liest die fuenf realen Pin-Stellen mit Tag und Digest" {
  run bash "$DF" --pins
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | wc -l)" -eq 5 ]
  for n in go-toolchain golangci-lint d-check d-check-emit a-check-emit; do
    printf '%s\n' "$output" | grep -qE "^$n\|[^|]+:[^|]+\|sha256:[0-9a-f]{64}\|[^|]+$"
  done
}

@test "digest-freshness: der Tag des go-toolchain-Pins ist GO_VERSION aus dem Makefile" {
  run bash "$DF" --pins
  [ "$status" -eq 0 ]
  mk="$(sed -n 's/^GO_VERSION ?= \([^ ]*\).*/\1/p' "$REPO/Makefile" | head -1)"
  [ -n "$mk" ]
  printf '%s\n' "$output" | grep -q "^go-toolchain|golang:$mk|"
}

@test "digest-freshness: der golang-Digest in --pins ist der des Dockerfile" {
  run bash "$DF" --pins
  d="$(sed -n 's/^FROM golang:[^@ ]*@\(sha256:[0-9a-f]\{64\}\) .*/\1/p' "$REPO/Dockerfile" | head -1)"
  [ -n "$d" ]
  printf '%s\n' "$output" | grep -q "^go-toolchain|[^|]*|$d|"
}
