#!/usr/bin/env bats
# span-emit.bats — Waechter fuer den Telemetrie-Emitter (slice-059, ADR-0011).
#
# Der Emitter haengt an JEDEM Tool-Call. Zwei seiner Eigenschaften sind deshalb
# nicht Komfort, sondern Betriebssicherheit — und beide werden hier gemessen,
# nicht zugesagt:
#   1. Er kann auf dem ENTSCHEIDUNGS-Kanal nicht sprechen (stdout leer, Exit 0),
#      auch wenn er innerlich scheitert. Ohne diese Klemme legte ein
#      Skript-Fehler den Lauf still, den er nur beobachten soll.
#   2. Er traegt KEIN Byte fremden Inhalts ins Log. Ein Audit-Log, das Secrets
#      sammelt, ist schlimmer als keines.
# Dazu die Ablage-Eigenschaften, an denen der Gate-Nachweis haengt.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  EMIT="$REPO/harness/tools/span-emit.sh"
  # Hermetisch: der Gate-Lauf mountet das Repo read-only, also schreibt der
  # Emitter hier in ein Temp-Verzeichnis. Dass der PRODUKTIONS-Pfad im
  # gitignorierten Zustands-Bereich liegt, prueft der Kopplungs-Test unten.
  SPANS="$BATS_TEST_TMPDIR/spans"
  export SPAN_DIR="$SPANS"
}

payload_bash() {
  printf '%s' '{"session_id":"s1","hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"t1","tool_input":{"command":"make gates --flag"}}'
}

# --- (1) Die Klemme -------------------------------------------------------

@test "span: der Emitter endet mit Exit 0, auch wenn seine Payload Muell ist" {
  run bash -c "printf '%s' 'kein json {{{' | bash '$EMIT'"
  [ "$status" -eq 0 ]
}

@test "span: der Emitter endet mit Exit 0, auch bei LEERER Eingabe" {
  run bash -c "printf '' | bash '$EMIT'"
  [ "$status" -eq 0 ]
}

# Der namensgebende Fall: das Skript scheitert INNERLICH. `awk` endet bei einem
# fatalen Fehler mit Exit 2 — genau dem Wert, mit dem ein Hook blockiert. Statt
# eine Datei zu praeparieren (das Repo ist im Gate-Lauf read-only), wird der
# gesamte Werkzeugkasten entzogen: ohne PATH scheitert JEDER innere Aufruf,
# darunter awk. Die Klemme muss das auffangen — und zwar in beiden Kanaelen.
@test "span: scheitert alles im Inneren, blockt der Emitter den Aufrufer trotzdem nicht" {
  # Der bash-Pfad wird VORHER aufgeloest und absolut eingesetzt: mit leerem PATH
  # fände die aufrufende Shell sonst schon `bash` nicht und schiede mit 127 aus,
  # bevor der Emitter startet — der Test hätte sich selbst gemessen statt die
  # Klemme. `/bin/bash` fest zu verdrahten ginge auch nicht: das bats-Image legt
  # bash woanders ab.
  local sh; sh="$(command -v bash)"
  run bash -c "printf '%s' '{\"tool_name\":\"Bash\"}' | env PATH=/nonexistent '$sh' '$EMIT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# stdout ist bei Hooks der ENTSCHEIDUNGS-Kanal. Er bleibt im gesunden Fall leer
# (hier) und im Fehlerfall (Test darueber) — beide Richtungen, weil nur beide
# zusammen die Zusage tragen. Kindprozesse sind mit abgedeckt: sie erben fd 1
# der Subshell, deren Ausgabe der Emitter verwirft.
@test "span: stdout bleibt leer, auch im gesunden Lauf" {
  run bash -c "printf '%s' '$(payload_bash)' | bash '$EMIT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- (2) Kein fremder Inhalt ---------------------------------------------

@test "span: eine Schreib-Payload hinterlaesst Pfad und Fingerabdruck, NIE den Inhalt" {
  printf '%s' '{"session_id":"s2","hook_event_name":"PostToolUse","tool_name":"Write","tool_use_id":"t2","tool_input":{"file_path":"README.md","content":"STRENG-GEHEIM-KANARIENVOGEL"}}' | bash "$EMIT"
  run cat "$SPANS/s2.jsonl"
  [ "$status" -eq 0 ]
  # Der Kanarienvogel darf nirgends auftauchen.
  [[ "$output" != *"KANARIENVOGEL"* ]]
  [[ "$output" == *'"path":"README.md"'* ]]
  [[ "$output" == *'"sha256_16"'* ]]
}

@test "span: von einer Kommandozeile bleibt nur das Programm, nie die Argumente" {
  printf '%s' '{"session_id":"s3","hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"t3","tool_input":{"command":"curl -H AUTHORIZATION-TOKEN-XYZ https://example.invalid"}}' | bash "$EMIT"
  run cat "$SPANS/s3.jsonl"
  [[ "$output" != *"AUTHORIZATION-TOKEN-XYZ"* ]]
  [[ "$output" == *'"program":"curl"'* ]]
}

# Der fail-closed Default: ein Werkzeug, das NICHT namentlich im Schema steht,
# gibt keine Argumente preis — auch kein Freitext-Prompt.
@test "span: ein unbekanntes Werkzeug gibt nur Name und Status preis" {
  printf '%s' '{"session_id":"s4","hook_event_name":"PostToolUse","tool_name":"Task","tool_use_id":"t4","tool_input":{"prompt":"VERTRAULICHER-PROMPT-TEXT","subagent_type":"x"}}' | bash "$EMIT"
  run cat "$SPANS/s4.jsonl"
  [[ "$output" != *"VERTRAULICHER-PROMPT-TEXT"* ]]
  [[ "$output" == *'"tool":"Task"'* ]]
  [[ "$output" == *'"status":"ok"'* ]]
}

# --- (3) Ablage und Folgenummer ------------------------------------------

@test "span: die Datei traegt Modus 0600, unabhaengig vom Verzeichnis" {
  payload_bash | bash "$EMIT"
  run stat -c '%a' "$SPANS/s1.jsonl"
  [ "$output" = "600" ]
}

@test "span: die Folgenummer steigt, und jeder (Sitzung, Agent) hat seinen eigenen Kreis" {
  payload_bash | bash "$EMIT"
  payload_bash | bash "$EMIT"
  printf '%s' '{"session_id":"s1","agent_id":"a9","hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"t9","tool_input":{"command":"ls"}}' | bash "$EMIT"
  run bash -c "grep -c seq '$SPANS/s1.jsonl'"
  [ "$output" = "2" ]
  run bash -c "grep -o '\"seq\":[0-9]*' '$SPANS/s1.jsonl' | tr '\n' ' '"
  [ "$output" = '"seq":1 "seq":2 ' ]
  # Der Subagent hat einen EIGENEN Strom, der wieder bei 1 beginnt.
  run bash -c "grep -o '\"seq\":[0-9]*' '$SPANS/s1-a9.jsonl'"
  [ "$output" = '"seq":1' ]
}

# Kopplung statt Zufall: der Default-Ablageort des Emitters MUSS in dem Pfad
# liegen, den .gitignore ausnimmt. Faellt eines von beidem weg, ginge jeder Span
# in den working-tree-hash ein und der Stop-Hook blockierte sich selbst
# (MR-003 / ADR-0011 Festlegung 3).
@test "span: der Default-Ablageort liegt im gitignorierten Zustands-Bereich" {
  run grep -c 'SPAN_DIR:-\.harness/state/spans' "$EMIT"
  [ "$output" = "1" ]
  run grep -c '^\.harness/state/$' "$REPO/.gitignore"
  [ "$output" = "1" ]
}

# --- (4) Korrelations-IDs -------------------------------------------------

@test "span: slice.id und requirement.id kommen aus dem Lifecycle, nicht aus der Payload" {
  payload_bash | bash "$EMIT"
  run cat "$SPANS/s1.jsonl"
  # Beide Felder sind vorhanden; ihr INHALT haengt am Lifecycle-Verzeichnis und
  # ist hier bewusst nicht festgenagelt (er wandert mit dem naechsten Slice).
  [[ "$output" == *'"slice":['* ]]
  [[ "$output" == *'"requirement":['* ]]
}
