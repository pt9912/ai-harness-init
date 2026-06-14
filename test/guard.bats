#!/usr/bin/env bats
# guard.bats — Verhaltens- und Parse-Tests fuer den Command-Guard
# (.claude/hooks/pretooluse-command-guard.sh) und den awk-Extraktor
# (tools/harness/extract-command.awk). Laeuft Docker-only im gepinnten
# bats-Image (`make test`; ADR-0003, ADR-0004; LH-FA-06, LH-QA-03).
#
# Deckt laut Slice-DoD: gueltige JSON -> korrekter Befehl; malformed -> block;
# blockierte vs. erlaubte Kommandos; bash -c-Verschachtelung; den Heredoc-/
# Commit-Message-Fall (bekannter, dokumentierter False-Positive).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  GUARD="$REPO/.claude/hooks/pretooluse-command-guard.sh"
  EXTRACT="$REPO/tools/harness/extract-command.awk"
}

guard()   { printf '%s' "$1" | bash "$GUARD"; }
extract() { printf '%s' "$1" | awk -f "$EXTRACT"; }

assert_blocked() {
  printf '%s' "$output" | grep -q '"decision": "block"' \
    || { echo "expected BLOCK, got: [$output]"; return 1; }
}
assert_passed() {
  [ -z "$output" ] || { echo "expected PASS (no output), got: [$output]"; return 1; }
}

# ---------- awk-Extraktor: gueltige JSON -> korrekter Befehl ----------

@test "extract: simpler Befehl" {
  run extract '{"tool_name":"Bash","tool_input":{"command":"ls -la","description":"x"}}'
  [ "$status" -eq 0 ]
  [ "$output" = "ls -la" ]
}

@test "extract: command nicht als erster Key" {
  run extract '{"tool_input":{"description":"run the command tool","command":"go build"}}'
  [ "$status" -eq 0 ]
  [ "$output" = "go build" ]
}

@test "extract: escapte Quotes im Befehl" {
  run extract '{"tool_input":{"command":"git commit -m \"fix: pip thing\""}}'
  [ "$status" -eq 0 ]
  [ "$output" = 'git commit -m "fix: pip thing"' ]
}

@test "extract: Decoy command-Key in Array und in escaptem Value" {
  run extract '{"a":[{"command":"trap"}],"tool_input":{"description":"he said \"command\": no","command":"docker run x"}}'
  [ "$status" -eq 0 ]
  [ "$output" = "docker run x" ]
}

# ---------- awk-Extraktor: Parse-Zweifel -> fail-closed (rc != 0) ----------

@test "extract: malformed/abgeschnitten -> rc!=0" {
  run extract '{"tool_input":{"command":"ls"'
  [ "$status" -ne 0 ]
}

@test "extract: leere Eingabe -> rc!=0" {
  run extract ''
  [ "$status" -ne 0 ]
}

@test "extract: \\u-Escape im Befehl -> rc!=0 (fail-closed)" {
  # command-Wert ist "\\u0067o build". Der Extraktor dekodiert \u NICHT,
  # sondern blockt — sonst koennte ein \u-kodierter Toolchain-Name am
  # Scan vorbei. Backslash aus Variable, damit das Escape im Testtext
  # nicht selbst dekodiert wird.
  bs='\'
  json="{\"tool_input\":{\"command\":\"${bs}u0067o build\"}}"
  run extract "$json"
  [ "$status" -ne 0 ]
}

# ---------- Guard: erlaubte Kommandos passieren ----------

@test "guard: make gates passt" {
  run guard '{"tool_input":{"command":"make gates"}}'
  assert_passed
}

@test "guard: git/docker/chmod passieren" {
  run guard '{"tool_input":{"command":"git mv a b"}}';                  assert_passed
  run guard '{"tool_input":{"command":"docker run --rm img npm test"}}'; assert_passed
  run guard '{"tool_input":{"command":"chmod +x x.sh"}}';               assert_passed
}

@test "guard: VAR=… Praefix und cd && make passieren" {
  run guard '{"tool_input":{"command":"FOO=1 make gates"}}'; assert_passed
  run guard '{"tool_input":{"command":"cd sub && make test"}}'; assert_passed
}

@test "guard: blockiertes Wort als Argument (commit-message) passt" {
  run guard '{"tool_input":{"command":"git commit -m \"install pip later\""}}'
  assert_passed
}

# ---------- Guard: Host-Toolchain wird blockiert ----------

@test "guard: go build blockt" {
  run guard '{"tool_input":{"command":"go build ./..."}}'
  assert_blocked
}

@test "guard: pip/npm/cargo/golangci-lint blocken" {
  run guard '{"tool_input":{"command":"pip install x"}}';     assert_blocked
  run guard '{"tool_input":{"command":"npm ci"}}';            assert_blocked
  run guard '{"tool_input":{"command":"cargo build"}}';       assert_blocked
  run guard '{"tool_input":{"command":"golangci-lint run"}}'; assert_blocked
}

@test "guard: sudo-Praefix und absoluter Pfad werden erkannt" {
  run guard '{"tool_input":{"command":"sudo apt-get update"}}';   assert_blocked
  run guard '{"tool_input":{"command":"/usr/bin/pip3 install x"}}'; assert_blocked
}

@test "guard: go in Subshell/Pipe/Command-Substitution blockt" {
  run guard '{"tool_input":{"command":"echo hi && (cd x && go test)"}}'; assert_blocked
  run guard '{"tool_input":{"command":"true | go env"}}';               assert_blocked
  run guard '{"tool_input":{"command":"echo $(go env GOPATH)"}}';       assert_blocked
}

# ---------- Härtung über node-Parität hinaus: & / |& als Segment-Grenze ----------

@test "guard: go im Hintergrund (einzelnes &) blockt" {
  run guard '{"tool_input":{"command":"sleep 1 & go run ./tool"}}'
  assert_blocked
}

@test "guard: go nach |& blockt" {
  run guard '{"tool_input":{"command":"make x |& go build > log"}}'
  assert_blocked
}

@test "guard: Background-& vor forbidden tool trennt Segmente" {
  run guard '{"tool_input":{"command":"make build & go test ./..."}}'
  assert_blocked
}

# ---------- Guard: bash -c-Verschachtelung ----------

@test "guard: bash -c \"go build\" blockt" {
  run guard '{"tool_input":{"command":"bash -c \"go build\""}}'
  assert_blocked
}

@test "guard: bash -lc (Flag-Buendel) mit cargo blockt" {
  run guard '{"tool_input":{"command":"bash -lc \"cargo build\""}}'
  assert_blocked
}

@test "guard: zu tiefe Verschachtelung -> fail-closed (block)" {
  run guard '{"tool_input":{"command":"bash -c bash -c bash -c bash -c ls"}}'
  assert_blocked
}

# ---------- Guard: fail-closed bei Parse-Zweifel ----------

@test "guard: malformed JSON -> block" {
  run guard '{"tool_input":{"command":'
  assert_blocked
}

@test "guard: leere Eingabe -> block" {
  run guard ''
  assert_blocked
}

# ---------- Regression: malformed \u darf NICHT fail-open gehen ----------

# Ein \u ohne 4 folgende Hex-Ziffern in einem String VOR command desyncte
# fueher den Scanner (i+=4 ueber das schliessende ") -> leerer Befehl ->
# Guard liess den echten Befehl durch. Muss fail-closed blocken.
@test "extract: malformed \\u (nicht 4 Hex) vor command -> rc!=0" {
  bs='\'
  json="{\"tool_input\":{\"description\":\"x${bs}u\",\"command\":\"npm ci\"}}"
  run extract "$json"
  [ "$status" -ne 0 ]
}

@test "guard: malformed \\u vor command -> block (kein fail-open)" {
  bs='\'
  json="{\"tool_input\":{\"description\":\"x${bs}u\",\"command\":\"npm ci\"}}"
  run guard "$json"
  assert_blocked
}

# ---------- Bekannter, dokumentierter False-Positive ----------

# Heredoc-Inhalt wird wie Kommando-Segmente zeilenweise gescannt: ein
# blockiertes Wort am Zeilenkopf eines Here-Document-Bodys loest den Guard
# aus, obwohl es Daten sind. Akzeptiert (Stolperdraht, keine Sandbox; ADR-0004)
# und hier festgehalten, damit die Eigenschaft sichtbar bleibt.
@test "guard: Heredoc mit blockiertem Wort am Zeilenkopf blockt (bekannter FP)" {
  run guard '{"tool_input":{"command":"cat <<EOF\npip install x\nEOF"}}'
  assert_blocked
}
