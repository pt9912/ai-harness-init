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
# allein sagt darueber nichts). Rot-Gegenbeispiele: test/mutations 120 (Zeichensatz
# des Typnamens gelockert) · 121/122 (Eltern-Pruefung des Key-Stacks weg, je fuer
# subagent_type und run_in_background) · 139 (fehlender Typ fail-open) · 150 (ein
# Rollen-Typ wird wieder abgewiesen).
#
# Deckt: fehlender Typ gilt als unlesbarer Aufruf · Parse-Zweifel -> verweigern ·
# ein lesbarer Typ laeuft durch, auch ein Rollen-Typ · der Fehlmatch, den ein
# Regex-Griff machen wuerde.
#
# Der Extraktor liest weiterhin BEIDE Felder, und seine Faelle stehen unveraendert:
# `run_in_background` ist aus dem Eingabe-Schema von `Agent` verschwunden, aus dem
# Extraktor nicht. Was der Guard davon liest, ist der Typ.

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

# ---------- Guard: lesbar oder nicht ----------

# Die Aufrufform, die es heute gibt: ein Typ, kein Schalter. Sie muss durchlaufen —
# und zwar fuer jeden Typ, den es gibt, denn die Betriebsart ist nicht mehr
# waehlbar (Messung: docs/reviews/2026-08-15-agent-guard-tool-vertrag.md).
@test "guard: lesbarer Typ ohne Schalter -> PASS" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"general-purpose","prompt":"x"}}'
  assert_passed
}

@test "guard: erfundener Typ -> PASS (der Guard fuehrt keine Typ-Liste)" {
  run guard '{"tool_name":"Agent","tool_input":{"subagent_type":"gibt-es-nicht","prompt":"x"}}'
  assert_passed
}

@test "guard: kaputte Eingabe -> DENY (fail-closed)" {
  run guard 'nicht mal JSON'
  assert_denied
}

# Der Guard haengt an "matcher": "Agent" — jeder Aufruf, den er sieht, ist ein
# Agenten-Aufruf. Fehlt darin der Typ, ist die Aufrufform nicht gelesen, sondern
# geraten. Gegenrichtung sind die PASS-Faelle darueber — ein VORHANDENER Typ laeuft
# durch, der Guard lehnt also nicht pauschal ab.
@test "guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)" {
  run guard '{"tool_name":"Agent","tool_input":{"prompt":"x"}}'
  assert_denied
}

# ---------- die Rollen laufen ----------

# Der Zahn unter der Aenderung, die den Guard von der Betriebsart geloest hat:
# KEIN Typ aus .claude/agents/ darf abgewiesen werden. Der Test faehrt ueber JEDE
# Datei im Verzeichnis — kommt eine Rolle hinzu, ist sie automatisch gedeckt.
# Rot wird er, sobald irgendein Zweig einen Rollen-Typ wieder verweigert
# (test/mutations/150-agentguard-rolle-abgewiesen.sh).
@test "guard: JEDER Typ in .claude/agents/ laeuft durch" {
  local n=0
  for f in "$REPO"/.claude/agents/*.md; do
    local name
    name="$(basename "$f" .md)"
    run guard "{\"tool_name\":\"Agent\",\"tool_input\":{\"subagent_type\":\"$name\",\"prompt\":\"x\"}}"
    assert_passed || { echo "Rolle $name wurde abgewiesen"; return 1; }
    n=$((n + 1))
  done
  [ "$n" -ge 6 ] || { echo "erwartet >=6 Rollen-Dateien, gefunden $n"; return 1; }
}
