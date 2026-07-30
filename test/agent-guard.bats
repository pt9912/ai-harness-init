#!/usr/bin/env bats
# agent-guard.bats — Verhaltens- und Parse-Tests fuer den Agent-Guard
# (.claude/hooks/pretooluse-agent-guard.sh) und den awk-Extraktor
# (harness/tools/extract-agent-call.awk). Laeuft Docker-only im gepinnten
# bats-Image (`make test`; ADR-0003, ADR-0004; LH-QA-03).
#
# Warum es diese Datei gibt: der Live-Beleg aus slice-060 DoD (1) ist EINMALIG
# (ein echter abgelehnter Aufruf, am 2026-07-30 rot gesehen). Er zeigt, dass der
# Guard griff — er merkt nicht, wenn er spaeter aufhoert zu greifen. Diese Tests
# sind der wiederholbare Teil.
#
# Und die dritte Ebene: dass DIESE Tests Zaehne haben, steht als staendiger Fall in
# test/mutations/ (AGENTS.md 3.6 — `make mutate` faehrt sie, ein gruener `make test`
# allein sagt darueber nichts). Rot-Gegenbeispiele: test/mutations 117 (Rollen-Frage
# weg -> der Guard lehnt alles ab) · 118 (Namensliste statt Ableitung — der einzige
# Fall, der abgeleitet von kopiert unterscheidet) · 119 (fehlender Schalter
# fail-open) · 120 (Zeichensatz des Typnamens gelockert) · 121/122 (Eltern-Pruefung
# des Key-Stacks weg, je fuer subagent_type und run_in_background).
#
# Deckt: die Unterscheidung Rolle/Nicht-Rolle · fehlender Schalter gilt als
# Hintergrund · Parse-Zweifel -> verweigern · der Fehlmatch, den ein Regex-Griff
# machen wuerde · die ABLEITUNG der Rollen-Liste aus dem Verzeichnis.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  GUARD="$REPO/.claude/hooks/pretooluse-agent-guard.sh"
  EXTRACT="$REPO/harness/tools/extract-agent-call.awk"
}

guard()   { printf '%s' "$1" | bash "$GUARD"; }
extract() { printf '%s' "$1" | awk -f "$EXTRACT"; }

# Der Agent-Guard verweigert ueber hookSpecificOutput.permissionDecision — die
# AKTUELLE Form. Der Nachbar-Guard nutzt das fuer PreToolUse veraltete
# Top-Level-decision; sein Nachzug ist slice-067. Deshalb prueft dieser Assert
# bewusst ein ANDERES Feld als der in guard.bats.
# Here-String statt `printf | grep -q`: eine Pipe in grep -q kann unter pipefail
# EPIPE geben und dann faelschlich "fehlt" melden.
assert_denied() {
  grep -q '"permissionDecision": "deny"' <<<"$output" \
    || { echo "expected DENY, got: [$output]"; return 1; }
}
assert_passed() {
  [ -z "$output" ] || { echo "expected PASS (no output), got: [$output]"; return 1; }
}

# ---------- awk-Extraktor ----------

@test "extract: Vordergrund -> false + Typ" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":false}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '1p' <<<"$output")" = "false" ]
  [ "$(sed -n '2p' <<<"$output")" = "reviewer" ]
}

@test "extract: Hintergrund -> true + Typ" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":true}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '1p' <<<"$output")" = "true" ]
}

@test "extract: fehlender Schalter -> ABSENT (nicht false)" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","prompt":"x"}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '1p' <<<"$output")" = "ABSENT" ]
}

# Der Grund fuer den zeichenweisen Scanner: ein Prompt ist Freitext und kann die
# Schluessel als TEXT enthalten. Ein sed/grep-Griff nimmt den ersten Treffer und
# entscheidet ueber die falsche Groesse.
@test "extract: Schluessel IM Prompt taeuschen den Scanner nicht" {
  run extract '{"tool_name":"Agent","tool_input":{"prompt":"schreib \"subagent_type\": \"planner\" und run_in_background: true","subagent_type":"reviewer","run_in_background":false}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '1p' <<<"$output")" = "false" ]
  [ "$(sed -n '2p' <<<"$output")" = "reviewer" ]
}

# Der Fehlmatch-Test oben belegt "Scanner schlaegt sed" — der Prompt ist dort ein
# EINZELNER String mit escapten Quotes, der Scanner kommt also nie in die Lage,
# Keys zu verwechseln. Die Eigenschaft, die der Key-STACK traegt, ist eine andere:
# nur der Pfad tool_input -> subagent_type zaehlt. Sie braucht echte
# Verschachtelung, sonst ist sie unbelegt (gefunden, weil eine Mutation am
# Key-Stack KEINEN Test rot machte).
# BEIDE Reihenfolgen, und das ist der Punkt: die Attrappe NACH dem echten Wert
# ist die mit Zaehnen. Steht sie davor, ueberschreibt der echte Wert sie auch in
# einer kaputten Fassung ("letzter Treffer gewinnt") und der Test bleibt gruen —
# so ist mein erster Versuch an zwei Key-Stack-Mutationen vorbeigelaufen.
@test "extract: subagent_type in VERSCHACHTELTEM Objekt zaehlt nicht (Attrappe danach)" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":false,"meta":{"subagent_type":"planner"}}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '2p' <<<"$output")" = "reviewer" ]
}

@test "extract: subagent_type in VERSCHACHTELTEM Objekt zaehlt nicht (Attrappe davor)" {
  run extract '{"tool_name":"Agent","tool_input":{"meta":{"subagent_type":"planner"},"subagent_type":"reviewer","run_in_background":false}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '2p' <<<"$output")" = "reviewer" ]
}

@test "extract: subagent_type auf TOP-Level zaehlt nicht (Attrappe danach)" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":false},"subagent_type":"planner"}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '2p' <<<"$output")" = "reviewer" ]
}

@test "extract: run_in_background ausserhalb tool_input zaehlt nicht (Attrappe danach)" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":false},"run_in_background":true}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '1p' <<<"$output")" = "false" ]
}

@test "extract: Pfad-Ausbruch im Typnamen -> exit 3" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"../../etc/passwd","run_in_background":true}}'
  [ "$status" -eq 3 ]
}

@test "extract: abgeschnittene JSON -> exit 3" {
  run extract '{"tool_name":"Agent","tool_input":{"subagent_type":"revie'
  [ "$status" -eq 3 ]
}

@test "extract: kein Subagent-Typ -> zweimal ABSENT" {
  run extract '{"tool_name":"Bash","tool_input":{"command":"ls"}}'
  [ "$status" -eq 0 ]
  [ "$(sed -n '2p' <<<"$output")" = "ABSENT" ]
}

# ---------- Guard: die Unterscheidung ----------

@test "guard: Rolle im Hintergrund -> DENY" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":true}}'
  assert_denied
}

@test "guard: Rolle ohne Schalter -> DENY (Abwesenheit gilt als Hintergrund)" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","prompt":"x"}}'
  assert_denied
}

@test "guard: Rolle im Vordergrund -> PASS" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":false}}'
  assert_passed
}

# Die Kehrseite, und der Unterschied zur Wegwerf-Sonde vom 2026-07-29: die hat
# JEDEN Agent-Aufruf ohne expliziten Vordergrund abgelehnt.
@test "guard: general-purpose im Hintergrund -> PASS (keine Rolle)" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"general-purpose","run_in_background":true}}'
  assert_passed
}

@test "guard: Explore im Hintergrund -> PASS (keine Rolle)" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"Explore","run_in_background":true}}'
  assert_passed
}

@test "guard: erfundener Typ im Hintergrund -> PASS (keine Datei, keine Rolle)" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"gibt-es-nicht","run_in_background":true}}'
  assert_passed
}

@test "guard: kaputte Eingabe -> DENY (fail-closed)" {
  run guard 'nicht mal JSON'
  assert_denied
}

# ---------- die ABLEITUNG, nicht die Kopie ----------

# Der Guard traegt keine Rollen-Liste; er prueft, ob .claude/agents/<name>.md
# existiert. Dieser Test faehrt die Ableitung ueber JEDE Datei im Verzeichnis:
# kommt eine Rolle hinzu, ist sie automatisch gedeckt; verschwindet eine, faellt
# es hier auf. Eine hart notierte Namensliste waere die vierte Kopie, die
# slice-060 gerade vermeidet.
@test "guard: JEDER Typ in .claude/agents/ wird im Hintergrund abgelehnt" {
  local n=0
  for f in "$REPO"/.claude/agents/*.md; do
    local name
    name="$(basename "$f" .md)"
    run guard "{\"tool_name\":\"Agent\",\"tool_input\":{\"subagent_type\":\"$name\",\"run_in_background\":true}}"
    assert_denied || { echo "Rolle $name wurde NICHT abgelehnt"; return 1; }
    n=$((n + 1))
  done
  [ "$n" -ge 6 ] || { echo "erwartet >=6 Rollen-Dateien, gefunden $n"; return 1; }
}

@test "guard: JEDER Typ in .claude/agents/ laeuft im Vordergrund durch" {
  for f in "$REPO"/.claude/agents/*.md; do
    local name
    name="$(basename "$f" .md)"
    run guard "{\"tool_name\":\"Agent\",\"tool_input\":{\"subagent_type\":\"$name\",\"run_in_background\":false}}"
    assert_passed || { echo "Rolle $name wurde faelschlich abgelehnt"; return 1; }
  done
}

# Und der Zahn zur Ableitung selbst: eine Fixture-Rolle, die es im Repo NICHT
# gibt. Der Guard muss sie ablehnen, ohne dass eine Zeile Code sie kennt. Eine
# hart notierte Namensliste — die Kopie, die slice-060 vermeidet — wuerde genau
# hier rot. Der bats-Lauf mountet das Repo read-only, deshalb die Naht
# AGENT_GUARD_AGENTS_DIR (im Guard begruendet).
@test "guard: eine ERFUNDENE Rolle im Fixture-Verzeichnis wird abgelehnt (Ableitung, keine Kopie)" {
  mkdir -p "$BATS_TEST_TMPDIR/agents"
  : >"$BATS_TEST_TMPDIR/agents/frisch-erfunden.md"
  AGENT_GUARD_AGENTS_DIR="$BATS_TEST_TMPDIR/agents" \
    run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"frisch-erfunden","run_in_background":true}}'
  assert_denied
}

@test "guard: im Fixture-Verzeichnis ist reviewer KEINE Rolle mehr -> PASS" {
  mkdir -p "$BATS_TEST_TMPDIR/agents"
  : >"$BATS_TEST_TMPDIR/agents/frisch-erfunden.md"
  AGENT_GUARD_AGENTS_DIR="$BATS_TEST_TMPDIR/agents" \
    run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"reviewer","run_in_background":true}}'
  assert_passed
}
