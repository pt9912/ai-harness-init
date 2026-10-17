#!/usr/bin/env bats
# digest-freshness.bats — Tests fuer die Digest-Achse (harness/tools/digest-freshness.sh,
# LH-QA-02 · seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor).
# Docker-only im gepinnten bats-Image (make test).
#
# HERMETISCH: getestet werden `--compare` (Fixture-Strings), `--pins` (liest die REALEN
# Pin-Stellen: Makefile, Dockerfile, d-check.mk, internal/emit) und die Hauptschleife ueber
# einen PATH-Stub `docker`, der je Tag den gepinnten Digest, einen anderen oder nichts liefert
# (Exit 0/1/2, Befund vor Fehler). Die Aufloesung gegen die Registry (Netz) wird hier NIE
# aufgerufen — sonst braeche `make test` (in gates) die offline-gruen-Zusage (LH-QA-01); sie
# ist allein `make freshness-digest`.

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

# Hauptschleife (Exit 0/1/2) ueber einen PATH-Stub `docker`, gegen die REALEN Pin-Dateien: der
# Stub liefert je Tag den gepinnten Digest aus `--pins` (STUB_MODE=gleich), einen anderen
# (STUB_DIFF = Tag-Teilstring), oder nichts mit Exit 1 (STUB_FAIL = Tag-Teilstring). Kein Netz.
stub_docker() {
  STUBDIR="$BATS_TEST_TMPDIR/stub"
  mkdir -p "$STUBDIR"
  bash "$DF" --pins >"$STUBDIR/pins.txt"
  cat >"$STUBDIR/docker" <<'STUB'
#!/usr/bin/env bash
ref="$4"
digest="$(awk -F'|' -v r="$ref" '$2 == r { print $3; exit }' "$STUB_PINS")"
[ -n "$digest" ] || exit 3
if [ -n "${STUB_FAIL:-}" ] && [[ "$ref" == *"$STUB_FAIL"* ]]; then exit 1; fi
if [ -n "${STUB_DIFF:-}" ] && [[ "$ref" == *"$STUB_DIFF"* ]]; then
  echo "sha256:$(printf '0%.0s' $(seq 64))"; exit 0
fi
echo "$digest"
STUB
  chmod +x "$STUBDIR/docker"
  export STUB_PINS="$STUBDIR/pins.txt"
  export PATH="$STUBDIR:$PATH"
}

@test "digest-freshness: Hauptschleife, jeder Digest gehoert zu seinem Tag -> exit 0" {
  stub_docker
  run bash "$DF"
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c ' aktuell ')" -eq 5 ]
}

@test "digest-freshness: Hauptschleife, ein Digest weicht ab -> exit 1" {
  stub_docker
  STUB_DIFF="golangci" run bash "$DF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"golangci-lint: DIGEST WEICHT AB"* ]]
}

@test "digest-freshness: Hauptschleife, Aufloesung schlaegt fuer einen Pin fehl -> exit 2" {
  stub_docker
  STUB_FAIL="golangci" run bash "$DF"
  [ "$status" -eq 2 ]
  [[ "$output" == *"FETCH-FEHLER"* ]]
}

@test "digest-freshness: Hauptschleife, Abweichung und Fehlschlag zugleich -> exit 1 geht vor 2" {
  stub_docker
  STUB_FAIL="golangci" STUB_DIFF="golang:" run bash "$DF"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FETCH-FEHLER"* ]]
  [[ "$output" == *"DIGEST WEICHT AB"* ]]
}
