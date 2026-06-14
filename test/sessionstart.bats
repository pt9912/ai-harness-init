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

@test "encode: C0-Steuerzeichen werden uXXXX-escapt (valides JSON)" {
  bs='\'
  run enc "$(printf 'a\fb')"
  [ "$output" = "a${bs}u000cb" ]
}


# ---------- Injektor ----------

# Der echte Cache ist gitignored/gefetcht (in CI abwesend) — daher gegen einen
# synthetischen Cache testen: vorhandener Cache -> Inhalt im Volltext injiziert.
@test "inject: vorhandener Cache wird im Volltext in additionalContext injiziert" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools" "$tmp/.harness/cache"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  printf '# Titel REGELTEST-7f3a\nzweite Zeile\n' > "$tmp/.harness/cache/agents-regelwerk.md"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'REGELTEST-7f3a'
  [[ "$output" != *'"additionalContext":""'* ]]
}

@test "inject: fehlender Cache -> Warnung mit Fetch-Befehl, exit 0 (degradiert sichtbar)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'make regelwerk-fetch'
}
