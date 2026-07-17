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

# Gegen eine synthetische Baseline testen (nicht gegen die echte): der Injektor
# ENTDECKT das <tag>-Verzeichnis (ein Tag zur Zeit, MR-007) — der Testname des
# Tags ist bewusst beliebig, damit ein hart verdrahteter Tag im Skript auffliegt.
# Vorhandener Index (README.md) wird injiziert; der Modul-Inhalt NICHT
# (Index-only, MR-006 — Module on-demand).
@test "inject: vorhandener Index (README.md) wird injiziert; Modul-Inhalt bleibt on-demand" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools" "$tmp/.harness/baseline/vTESTTAG-1a2b/regelwerk"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  printf '# Modul-Index INDEXTEST-7f3a\n- [Konventionen](grundlagen-konventionen.md)\n' \
    > "$tmp/.harness/baseline/vTESTTAG-1a2b/regelwerk/README.md"
  printf '# Konventionen MODULTEST-9c2b\n' \
    > "$tmp/.harness/baseline/vTESTTAG-1a2b/regelwerk/grundlagen-konventionen.md"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'INDEXTEST-7f3a'
  # Der entdeckte Tag steht im Pointer-Praefix — belegt, dass er nicht geraten wird
  printf '%s' "$output" | grep -q 'vTESTTAG-1a2b'
  # Index-only: der Modul-Inhalt selbst wird NICHT injiziert (nur on-demand lesbar)
  ! printf '%s' "$output" | grep -q 'MODULTEST-9c2b'
  [[ "$output" != *'"additionalContext":""'* ]]
}

# Die Baseline ist committet — ihr Fehlen heisst kaputter Checkout, nicht
# "noch nicht gefetcht". Die Warnung darf daher KEINEN Fetch-Befehl mehr nennen
# (es gibt keinen; das waere ein halluziniertes Kommando, LH-QA-01).
@test "inject: fehlende Baseline -> Warnung ohne Fetch-Befehl, exit 0 (degradiert sichtbar)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'baseline-verify'
  ! printf '%s' "$output" | grep -q 'regelwerk-fetch'
}

# Unvollstaendige Baseline: <tag>-Verzeichnis existiert, aber der Index fehlt.
# Als eigener Test fixiert, damit ein Lockern des Checks auf "Verzeichnis
# existiert" nicht still durchrutscht.
@test "inject: Baseline ohne Index -> Warnung, exit 0 (Index fehlt)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools" "$tmp/.harness/baseline/vTESTTAG-1a2b/regelwerk"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  printf '# nur ein Modul, kein Index\n' \
    > "$tmp/.harness/baseline/vTESTTAG-1a2b/regelwerk/grundlagen-konventionen.md"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'baseline-verify'
}

# Mehrdeutigkeit: zwei <tag>-Verzeichnisse verletzen die Setzung "ein Tag zur
# Zeit" (MR-007). Der Injektor darf sich dann NICHT still einen aussuchen —
# sonst injiziert er unbemerkt den falschen Stand.
@test "inject: zwei <tag>-Verzeichnisse -> Warnung, kein Index, exit 0 (Setzung verletzt)" {
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/harness/tools" \
    "$tmp/.harness/baseline/vTESTTAG-alt/regelwerk" \
    "$tmp/.harness/baseline/vTESTTAG-neu/regelwerk"
  cp "$INJECT" "$tmp/harness/tools/"
  cp "$ENCODER" "$tmp/harness/tools/"
  printf '# Index INDEXTEST-alt\n' > "$tmp/.harness/baseline/vTESTTAG-alt/regelwerk/README.md"
  printf '# Index INDEXTEST-neu\n' > "$tmp/.harness/baseline/vTESTTAG-neu/regelwerk/README.md"
  run bash "$tmp/harness/tools/sessionstart-inject-regelwerk.sh"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q '"hookEventName":"SessionStart"'
  printf '%s' "$output" | grep -q 'ein Tag zur Zeit'
  # kein Index injiziert — weder der eine noch der andere
  ! printf '%s' "$output" | grep -q 'INDEXTEST-alt'
  ! printf '%s' "$output" | grep -q 'INDEXTEST-neu'
}
