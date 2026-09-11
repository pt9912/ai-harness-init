#!/usr/bin/env bats
# commit-msg-guard.bats — Tests fuer den PreToolUse-Zusatz-Hook
# (.claude/hooks/pretooluse-commit-msg-guard.sh), der einen `git commit -F
# <datei>`-Aufruf mit einer kennungslosen Message-Datei blockt (AGENTS.md §5,
# harness/README.md §Traceability, AGENTS.md 3.6).
#
# Docker-only im gepinnten bats-Image (make test) — HERMETISCH: die reale
# Pruef-Instanz (`make commit-msg-check`, docker/d-check) wird NIE aufgerufen;
# das gepinnte bats-Image faehrt ohne Docker und ohne `git`
# (test/history-range-guard.bats-Nachbarschaft, harness/tools/slice-mv.sh
# Kopf, Abschnitt ZUSAGE). Ersetzt wird die Pruef-Instanz ueber
# PRETOOLUSE_COMMIT_MSG_CHECKER (Skript-eigener Ausbruchspunkt, s. Skriptkopf).
# Der reale docker-Lauf gegen `make commit-msg-check MSG=<datei>` steht in
# harness/README.md — ein realer Docker-Lauf gehoert nicht in einen
# hermetischen bats-Fall.
#
# Die Match-Extraktion (`--match`) ist der git-/docker-unabhaengige Teil und
# wird direkt geprueft; der volle Hook-Pfad (stdin-JSON -> Match -> Datei
# existiert -> Pruef-Instanz -> Block-JSON) mit der Stub-Pruef-Instanz.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  GUARD="$REPO/.claude/hooks/pretooluse-commit-msg-guard.sh"
  TMP="$(mktemp -d)"
  MSGFILE="$TMP/msg.txt"
  printf 'irgendeine Message' > "$MSGFILE"
}

teardown() {
  rm -rf "$TMP"
}

match() { bash "$GUARD" --match "$1"; }

hook() {  # $1 = JSON-Eingabe, $2 = Checker-Skript (leer = kein Override)
  if [ -n "${2:-}" ]; then
    PRETOOLUSE_COMMIT_MSG_CHECKER="$2" bash "$GUARD" <<<"$1"
  else
    bash "$GUARD" <<<"$1"
  fi
}

assert_blocked() {
  printf '%s' "$output" | grep -q '"decision": "block"' \
    || { echo "expected BLOCK, got: [$output]"; return 1; }
}
assert_passed() {
  [ -z "$output" ] || { echo "expected PASS (no output), got: [$output]"; return 1; }
}

# ---------- --match: git-commit-Form erkennen ----------

@test "match: git commit -F <datei> -> Datei auf stdout, exit 0" {
  run match 'git commit -F /tmp/x.txt'
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/x.txt" ]
}

@test "match: relativer Pfad wird unveraendert durchgereicht" {
  run match 'git commit -F rel/path.txt'
  [ "$status" -eq 0 ]
  [ "$output" = "rel/path.txt" ]
}

@test "match: Praefix (VAR=…) und Folge-Flags stoeren nicht" {
  run match 'FOO=1 git commit -F .git/COMMIT_MSG -a'
  [ "$status" -eq 0 ]
  [ "$output" = ".git/COMMIT_MSG" ]
}

@test "match: git commit -m (nicht die Repo-Konvention) -> kein Treffer" {
  run match 'git commit -m "foo"'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "match: kein git commit -> kein Treffer" {
  run match 'ls -la'
  [ "$status" -eq 1 ]
}

@test "match: git commit ohne -F -> kein Treffer" {
  run match 'git commit'
  [ "$status" -eq 1 ]
}

@test "match: -F \"<pfad-mit-variable>\" (doppelte Anfuehrungszeichen) -> Inhalt unexpandiert" {
  run match 'git commit -F "$msgfile"'
  [ "$status" -eq 0 ]
  [ "$output" = '$msgfile' ]
}

@test "match: -F '<pfad-mit-leerzeichen>' (einfache Anfuehrungszeichen) -> Inhalt inkl. Leerzeichen" {
  run match "git commit -F '/tmp/a b.txt'"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/a b.txt" ]
}

@test "match: --file=<pfad> -> Datei auf stdout" {
  run match 'git commit --file=.git/MSG'
  [ "$status" -eq 0 ]
  [ "$output" = ".git/MSG" ]
}

@test "match: --file <pfad> (mit Leerzeichen statt =) -> Datei auf stdout" {
  run match 'git commit --file .git/MSG'
  [ "$status" -eq 0 ]
  [ "$output" = ".git/MSG" ]
}

@test "match: -qF <pfad> (kombiniertes Kurz-Flag, F am Ende) -> Datei auf stdout" {
  run match 'git commit -qF .git/MSG'
  [ "$status" -eq 0 ]
  [ "$output" = ".git/MSG" ]
}

# ---------- voller Hook-Pfad: Datei-Existenz vor der Pruef-Instanz ----------

@test "hook: Datei existiert nicht -> PASS, Pruef-Instanz wird NICHT aufgerufen" {
  marker="$TMP/checker-called"
  cat > "$TMP/checker.sh" <<EOF
#!/usr/bin/env bash
touch "$marker"
exit 1
EOF
  chmod +x "$TMP/checker.sh"
  run hook "{\"tool_input\":{\"command\":\"git commit -F $TMP/does-not-exist.txt\"}}" "$TMP/checker.sh"
  assert_passed
  [ ! -e "$marker" ]
}

@test "hook: -F - (stdin-Form) -> PASS ohne Pruef-Instanz" {
  marker="$TMP/checker-called"
  cat > "$TMP/checker.sh" <<EOF
#!/usr/bin/env bash
touch "$marker"
exit 1
EOF
  chmod +x "$TMP/checker.sh"
  run hook '{"tool_input":{"command":"git commit -F -"}}' "$TMP/checker.sh"
  assert_passed
  [ ! -e "$marker" ]
}

@test "hook: kein git commit -> PASS" {
  run hook '{"tool_input":{"command":"ls -la"}}' ""
  assert_passed
}

@test "hook: kaputtes JSON -> PASS (der Command-Guard entscheidet fail-closed)" {
  run hook 'nicht mal JSON' ""
  assert_passed
}

# ---------- voller Hook-Pfad: Pruef-Instanz entscheidet ----------

@test "hook: Pruef-Instanz OK (Kennung vorhanden) -> PASS" {
  cat > "$TMP/checker-ok.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$TMP/checker-ok.sh"
  run hook "{\"tool_input\":{\"command\":\"git commit -F $MSGFILE\"}}" "$TMP/checker-ok.sh"
  assert_passed
}

@test "hook: Pruef-Instanz FAIL (Kennung fehlt) -> BLOCK mit Dateiname in der Begruendung" {
  cat > "$TMP/checker-fail.sh" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
  chmod +x "$TMP/checker-fail.sh"
  run hook "{\"tool_input\":{\"command\":\"git commit -F $MSGFILE\"}}" "$TMP/checker-fail.sh"
  assert_blocked
  printf '%s' "$output" | grep -qF "$MSGFILE"
  printf '%s' "$output" | grep -qF "make commit-msg-check MSG="
}

@test "hook: die Pruef-Instanz bekommt den ABSOLUTEN Pfad der Message-Datei" {
  argfile="$TMP/checker-arg.txt"
  cat > "$TMP/checker-echo.sh" <<EOF
#!/usr/bin/env bash
printf '%s' "\$1" > "$argfile"
exit 0
EOF
  chmod +x "$TMP/checker-echo.sh"
  run hook "{\"tool_input\":{\"command\":\"git commit -F $MSGFILE\"}}" "$TMP/checker-echo.sh"
  [ "$(cat "$argfile")" = "$MSGFILE" ]
}
