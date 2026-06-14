#!/usr/bin/env bats
# sessionstart.bats — Tests für den SessionStart-Regelwerk-Injektor
# (harness/tools/sessionstart-inject-regelwerk.sh) und den JSON-Encoder
# (harness/tools/json-encode.awk). Docker-only im gepinnten bats-Image
# (make test; slice-007 / MR-004 / LH-QA-03 / LH-QA-02).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  INJECT="$REPO/harness/tools/sessionstart-inject-regelwerk.sh"
  ENCODER="$REPO/harness/tools/json-encode.awk"
}

enc() { printf '%s' "$1" | awk -f "$ENCODER"; }

# ---------- JSON-Encoder ----------

@test "encode: Anführungszeichen wird escapt" {
  run enc 'a"b'
  [ "$output" = 'a\"b' ]
}

@test "encode: Backslash wird verdoppelt" {
  run enc 'a\b'
  [ "$output" = 'a\\b' ]
}

@test "encode: Tab wird \\t" {
  run enc "$(printf 'a\tb')"
  [ "$output" = 'a\tb' ]
}

@test "encode: Zeilenumbruch wird \\n" {
  run enc "$(printf 'a\nb')"
  [ "$output" = 'a\nb' ]
}

@test "encode: UTF-8 bleibt byteweise erhalten" {
  run enc 'café über'
  [ "$output" = 'café über' ]
}

# ---------- Injektor ----------

@test "inject: Cache vorhanden -> SessionStart-Wrapper, additionalContext nicht leer" {
  run bash "$INJECT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q '"additionalContext":"'
  [[ "$output" != *'"additionalContext":""'* ]]
}

@test "inject: additionalContext enthält den Sentinel-Marker (Verifikation)" {
  run bash "$INJECT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AIHARNESS-REGELWERK-SENTINEL'
}

@test "inject: fehlender Cache -> leerer additionalContext, exit 0 (degradiert leise)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  [ "$output" = '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}' ]
}
