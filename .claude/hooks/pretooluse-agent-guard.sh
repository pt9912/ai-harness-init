#!/usr/bin/env bash
# pretooluse-agent-guard — verweigert jeden Agenten-Aufruf, den er nicht eindeutig
# lesen kann. Was er entscheidet, ist die AUFRUFFORM vor dem Start; ueber den
# Ausgang des Laufs entscheidet er nicht mit.
#
# DIE BETRIEBSART PRUEFT ER NICHT, UND ZWAR MANGELS FELD. Das Eingabe-Schema von
# `Agent` fuehrt kein `run_in_background` mehr, und Subagenten starten im
# Hintergrund; eine Vordergrund-Form ist nicht anforderbar. Eine Forderung danach
# waere eine Bedingung, die kein Aufruf erfuellen kann — sie hat jeden der sechs
# Rollen-Agenten abgewiesen. Der Vertrag samt Gegenprobe ist gemessen in
# docs/reviews/2026-08-15-agent-guard-tool-vertrag.md; dort steht auch, was der
# Hintergrund-Lauf an Telemetrie kostet: die Rollen-Achse traegt weiter, das
# Kosten-Aggregat des Aufrufs faellt aus. ER SETZT DIE BETRIEBSART AUCH NICHT EIN, UND
# DIESER WEG IST GEFAHREN: ein Hook, der `run_in_background: false` per `updatedInput`
# nach dem Modell einsetzt, stellt die Vordergrund-Form nicht her — der so gestartete
# Lauf lief im Hintergrund (2026-08-21, docs/reviews/2026-08-21-updatedinput-messung.md).
# Dass die Hook-Ausgabe dabei uebernommen wurde, ist eine SICHT am Dialog und im Repo
# nicht nachpruefbar; dasselbe Dokument fuehrt das als Grenze. Gefuehrt wird dieser
# Ausfall als docs/plan/carveouts/CO-002-token-achse-je-rolle.md — dort stehen
# Geltungsbereich, Aufloesungs-Trigger und die Messung, die ihn entscheidet; wie sie
# ausgegangen ist, sagt der Status im Kopf jener Datei.
#
# Reines bash + awk, KEIN node/jq (LH-QA-03): der Extraktor
# (harness/tools/extract-agent-call.awk) zieht zwei Felder aus der Hook-stdin-JSON,
# gelesen wird hier das zweite — der Subagenten-Typ.
#
# Fail-closed antworten VIER Zweige, nicht jeder Eingang: fehlendes awk und
# fehlender Extraktor (UNBEWACHT, nicht unbewachbar), Parse-Zweifel (nur
# test/agent-guard.bats) und fehlender Typ (test/mutations/139) bei JEDEM Aufruf.
#
# EIN LESBARER TYP LAEUFT DURCH, auch ein Rollen-Typ. Sensor:
# test/agent-guard.bats, "JEDER Typ in .claude/agents/ laeuft durch"; Dauer-Sensor
# test/mutations/150-agentguard-rolle-abgewiesen.sh.
#
# AUSGABEFORM ist hookSpecificOutput.permissionDecision — die AKTUELLE. Das
# Top-Level-decision/reason des Nachbar-Guards (pretooluse-command-guard.sh) ist
# fuer PreToolUse VERALTET und funktioniert nur ueber eine
# Abwaertskompatibilitaets-Abbildung; dessen Nachzug ist slice-067, nicht dieser
# Hook. Vorbild ist also der Mechanismus des Nachbarn, nicht sein Format.
#
# Im Pass-Fall: KEINE Ausgabe — "allow" wuerde das Permission-System
# ueberspringen; ohne Ausgabe laeuft die normale Permission-Entscheidung.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
extractor="$here/../../harness/tools/extract-agent-call.awk"

emit_deny() {
  # $1 = Grund (erscheint WOERTLICH beim Aufrufer — am 2026-08-15 erneut gemessen).
  cat <<JSON
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "$1"
  }
}
JSON
}

input="$(cat)"

# Ohne awk keine Pruefung -> fail-closed (awk ist POSIX-Basis; ADR-0004).
command -v awk >/dev/null 2>&1 ||
  { emit_deny "Agent-Guard: awk fehlt, keine Pruefung moeglich (fail-closed)."; exit 0; }
[ -f "$extractor" ] ||
  { emit_deny "Agent-Guard: Extraktor fehlt ($extractor), keine Pruefung moeglich (fail-closed)."; exit 0; }

set +e
parsed="$(printf '%s' "$input" | awk -f "$extractor")"
rc=$?
set -e
[ "$rc" -ne 0 ] &&
  { emit_deny "Agent-Guard: Aufruf nicht eindeutig lesbar (Parse-Zweifel, fail-closed)."; exit 0; }

stype="$(sed -n '2p' <<<"$parsed")"

# Kein lesbarer Subagent-Typ -> verweigern. Der Hook haengt an "matcher": "Agent";
# was er sieht, IST ein Agenten-Aufruf, und ohne den Typ ist die Aufrufform nicht
# gelesen, sondern geraten. Das dokumentierte Eingabe-Schema von Agent fuehrt
# subagent_type (docs/user/claude-hooks-referenz.md, Abschnitt Agent) — eine Payload
# ohne ihn ist keine bekannte Aufrufform. Sensor: test/agent-guard.bats,
# "guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)"; Dauer-Sensor
# test/mutations/139-agentguard-typ-failopen.sh.
[ "$stype" = "ABSENT" ] && { emit_deny "Agent-Guard: Aufruf ohne lesbaren subagent_type (fail-closed). Ohne Typ ist die Aufrufform nicht gelesen, sondern geraten."; exit 0; }

exit 0
