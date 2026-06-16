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

# Der echte Cache ist gitignored/gefetcht (in CI abwesend) — daher gegen ein
# synthetisches Cache-Verzeichnis testen: vorhandener Index (README.md) wird
# injiziert; der Modul-Inhalt NICHT (Index-only, MR-006 — Module on-demand).
@test "inject: vorhandener Index (README.md) wird injiziert; Modul-Inhalt bleibt on-demand" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools" "$tmp/.harness/cache/agents-regelwerk"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  printf '# Modul-Index INDEXTEST-7f3a\n- [Konventionen](grundlagen-konventionen.md)\n' \
    > "$tmp/.harness/cache/agents-regelwerk/README.md"
  printf '# Konventionen MODULTEST-9c2b\n' \
    > "$tmp/.harness/cache/agents-regelwerk/grundlagen-konventionen.md"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'INDEXTEST-7f3a'
  # Index-only: der Modul-Inhalt selbst wird NICHT injiziert (nur on-demand lesbar)
  ! printf '%s' "$output" | grep -q 'MODULTEST-9c2b'
  [[ "$output" != *'"additionalContext":""'* ]]
}

@test "inject: fehlendes Cache-Verzeichnis -> Warnung mit Fetch-Befehl, exit 0 (degradiert sichtbar)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'make regelwerk-fetch'
}

# Teil-Fetch/Korruption: Verzeichnis existiert, aber der Index (README.md) fehlt.
# Derselbe Codepfad wie "kein Verzeichnis" ([ ! -f "$index" ]) -> sichtbare Warnung;
# als eigener Test fixiert, damit ein Lockern des Checks auf "Verzeichnis existiert"
# nicht still durchrutscht.
@test "inject: Verzeichnis ohne README.md -> Warnung mit Fetch-Befehl, exit 0 (Index fehlt)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools" "$tmp/.harness/cache/agents-regelwerk"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  printf '# nur ein Modul, kein Index\n' \
    > "$tmp/.harness/cache/agents-regelwerk/grundlagen-konventionen.md"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'make regelwerk-fetch'
}
