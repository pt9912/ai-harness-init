#!/usr/bin/env bats
# traeger-pins-check.bats — Zaehne fuer die Paarungs-Logik von `make traeger-pins-check`
# (LH-QA-02, ADR-0058, ADR-0059): je Plattform Dateiname gegen Digest, die drei Exit-Klassen,
# der Plattformname in der Meldung, die Exit-Zeile.
#
# WAS DIESE DATEI HAELT UND WAS NICHT: sie laeuft ueber einer NACHGEBAUTEN SHA256SUMS und
# einem docker-Stub (die einzige Grenze, die ersetzt ist; das Skript laeuft real). Sie haelt
# die Paarungs-Logik. Sie haelt NICHT die realen Pins des Makefile gegen das reale Release:
# die Pins kommen hier aus der Umgebung des Tests, nicht aus dem Makefile, und die Fixture
# traegt erfundene Digests. Den realen Pin faerbt allein ein Lauf von
# `make traeger-pins-check` am veroeffentlichten Release; kein Wächter hält ihn, Träger ist der
# Release-Schnitt (docs/user/releasing.md, Bindepunkt nach Schritt 5).
#
# ROT-GEGENPROBEN (AGENTS.md 3.6):
#   - Paart das Skript nach Zeilenposition statt nach Name, faerbt der Fall "Paarung nach
#     Name" rot (die Fixture fuehrt die Zeilen in anderer Folge als die Plattform-Folge);
#     Mutations-Fall test/mutations/774-traeger-pins-paarung-nach-position.sh.
#   - Vergleicht das Skript nicht alle sechs oder nennt es die Plattform nicht, faerbt der
#     Fall "genau die verfaelschte Plattform" rot.
#
# NETZLOS, laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKRIPT="$REPO/harness/tools/traeger-pins-check.sh"
  TMP="$BATS_TEST_TMPDIR"
  SHIM="$TMP/bin"
  mkdir -p "$SHIM"
  # docker-Stub: protokolliert Argumente, liefert die Fixture auf stdout oder endet mit
  # $STUB_RC.
  cat >"$SHIM/docker" <<'ENDE'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$STUB_LOG"
if [ -n "${STUB_RC:-}" ]; then
  echo "curl: (22) The requested URL returned error: 404" >&2
  exit "$STUB_RC"
fi
cat "$STUB_SUMS"
ENDE
  chmod +x "$SHIM/docker"
  export PATH="$SHIM:$PATH"
  export STUB_LOG="$TMP/docker.log"
  : >"$STUB_LOG"
  export STUB_SUMS="$TMP/sums"
  unset STUB_RC TAG TRAEGER_IMAGE
  export TRAEGER_TAG=v9.9.9
  # Die sechs Pins: erfundene, je Plattform verschiedene Digests.
  export TRAEGER_SHA256_LINUX_AMD64=aa01
  export TRAEGER_SHA256_LINUX_ARM64=aa02
  export TRAEGER_SHA256_DARWIN_AMD64=aa03
  export TRAEGER_SHA256_DARWIN_ARM64=aa04
  export TRAEGER_SHA256_WINDOWS_AMD64=aa05
  export TRAEGER_SHA256_WINDOWS_ARM64=aa06
  # Fixture in einer Folge, die NICHT die Plattform-Folge des Skripts ist (Windows zuerst,
  # Linux zuletzt, innerhalb der Paare vertauscht): nur die Paarung nach Name besteht.
  sums_schreiben aa06 aa05 aa04 aa03 aa02 aa01
}

# sums_schreiben <win-arm64> <win-amd64> <darwin-arm64> <darwin-amd64> <linux-arm64> <linux-amd64>
sums_schreiben() {
  printf '%s  ai-harness-init-windows-arm64.exe\n%s  ai-harness-init-windows-amd64.exe\n%s  ai-harness-init-darwin-arm64\n%s  ai-harness-init-darwin-amd64\n%s  ai-harness-init-linux-arm64\n%s  ai-harness-init-linux-amd64\n' \
    "$@" >"$STUB_SUMS"
}

letzte_zeile() { printf '%s\n' "$output" | tail -n 1; }

@test "paarung nach name: gleiche Pins in anderer Zeilenfolge enden mit Exit 0" {
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gleich — alle 6 Pins halten gegen die SHA256SUMS von v9.9.9"* ]]
  [[ "$output" != *"Exit "* ]]
}

@test "paarung nach name: zwei vertauschte Digests enden mit Exit 1 und nennen beide Plattformen" {
  sums_schreiben aa05 aa06 aa04 aa03 aa02 aa01
  run bash "$SKRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"TRAEGER_SHA256_WINDOWS_AMD64 weicht ab"* ]]
  [[ "$output" == *"TRAEGER_SHA256_WINDOWS_ARM64 weicht ab"* ]]
  [[ "$output" == *"Unterschied bei 2 von 6 Plattformen"* ]]
}

@test "genau die verfaelschte plattform: ein Pin weicht ab, nur seine Plattform wird genannt" {
  export TRAEGER_SHA256_DARWIN_AMD64=ff03
  run bash "$SKRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"TRAEGER_SHA256_DARWIN_AMD64 weicht ab — Pin ff03, SHA256SUMS von v9.9.9 fuehrt aa03 fuer ai-harness-init-darwin-amd64"* ]]
  [[ "$output" != *"TRAEGER_SHA256_LINUX"* ]]
  [[ "$output" != *"TRAEGER_SHA256_WINDOWS"* ]]
  [[ "$output" != *"TRAEGER_SHA256_DARWIN_ARM64"* ]]
  [[ "$output" == *"Unterschied bei 1 von 6 Plattformen"* ]]
}

@test "jede der sechs plattformen faerbt rot, wenn ihr Pin abweicht" {
  for p in LINUX_AMD64 LINUX_ARM64 DARWIN_AMD64 DARWIN_ARM64 WINDOWS_AMD64 WINDOWS_ARM64; do
    run env "TRAEGER_SHA256_$p=ff" bash "$SKRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"TRAEGER_SHA256_$p weicht ab"* ]]
  done
}

@test "exit-zeile: bei Exit 1 und Exit 2 die letzte stderr-Zeile, genau einmal" {
  export TRAEGER_SHA256_LINUX_ARM64=ff02
  run bash "$SKRIPT"
  [ "$status" -eq 1 ]
  [ "$(letzte_zeile)" = "traeger-pins-check: Exit 1" ]
  [ "$(printf '%s\n' "$output" | grep -c '^traeger-pins-check: Exit ')" -eq 1 ]
  STUB_RC=22 run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [ "$(letzte_zeile)" = "traeger-pins-check: Exit 2" ]
  [ "$(printf '%s\n' "$output" | grep -c '^traeger-pins-check: Exit ')" -eq 1 ]
}

@test "exit 2: Asset nicht abrufbar nennt die Ursache und vergleicht nichts" {
  STUB_RC=22 run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"SHA256SUMS von https://github.com/pt9912/ai-harness-init/releases/download/v9.9.9/SHA256SUMS nicht abrufbar (docker Exit 22) — es wurde nichts verglichen"* ]]
}

@test "exit 2: leere SHA256SUMS" {
  : >"$STUB_SUMS"
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"ist leer — es wurde nichts verglichen"* ]]
}

@test "exit 2: fehlender Eintrag nennt Asset und Plattform, auch wenn ein anderer Pin abweicht" {
  grep -v 'windows-amd64' "$STUB_SUMS" >"$STUB_SUMS.neu"
  mv "$STUB_SUMS.neu" "$STUB_SUMS"
  export TRAEGER_SHA256_LINUX_AMD64=ff01
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"ai-harness-init-windows-amd64.exe fehlt in den SHA256SUMS von v9.9.9"* ]]
  [[ "$output" == *"WINDOWS_AMD64"* ]]
}

@test "exit 2: ein doppelter Eintrag ist nicht eindeutig" {
  printf 'aa01  ai-harness-init-linux-amd64\n' >>"$STUB_SUMS"
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"ai-harness-init-linux-amd64 steht mehrfach"* ]]
}

@test "exit 2: ein fehlender Pin bricht vor jedem docker-Aufruf" {
  unset TRAEGER_SHA256_WINDOWS_ARM64
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"TRAEGER_SHA256_WINDOWS_ARM64 ist nicht gesetzt"* ]]
  [ ! -s "$STUB_LOG" ]
}

@test "exit 2: Tag fehlt oder hat eine falsche Form, ohne docker-Aufruf" {
  unset TRAEGER_TAG
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"weder TAG noch TRAEGER_TAG ist gesetzt"* ]]
  TAG='v1.2' run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Tag-Form falsch"* ]]
  TAG='v1.2.3;x' run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [ ! -s "$STUB_LOG" ]
}

@test "tag: TAG schlaegt TRAEGER_TAG, die URL traegt den Tag, das Bild ist der Pin von traeger-fetch" {
  TAG=v1.2.3 run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'PINS_SUMS_URL=https://github.com/pt9912/ai-harness-init/releases/download/v1.2.3/SHA256SUMS' "$STUB_LOG"
  [[ "$output" == *"von v1.2.3"* ]]
  pin="$(grep -m1 '^TRAEGER_IMAGE="' "$REPO/harness/tools/traeger-fetch.sh" | sed 's/^[^:]*:-//; s/}"$//')"
  case "$pin" in *@sha256:*) ;; *) false ;; esac
  grep -qF " $pin sh -c" "$STUB_LOG"
}

@test "bild: ein nicht digest-gepinntes TRAEGER_IMAGE bricht mit Exit 2" {
  TRAEGER_IMAGE=curlimages/curl:latest run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"kein digest-gepinntes Transport-Bild"* ]]
  [ ! -s "$STUB_LOG" ]
}

@test "kein gate: das Makefile fuehrt das Ziel, gates und record-gates nennen es nicht" {
  grep -qE '^traeger-pins-check: ##' "$REPO/Makefile"
  ! grep -E '^(gates|record-gates):' "$REPO/Makefile" | grep -qF 'traeger-pins-check'
}

@test "name exakt: ein Fremd-Eintrag, dessen Name den Asset-Namen enthaelt, stoert die Paarung nicht" {
  printf 'bb01  ai-harness-init-linux-amd64.sig\nbb02  ai-harness-init-windows-arm64.exe.sig\n' >>"$STUB_SUMS"
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gleich — alle 6 Pins"* ]]
}
