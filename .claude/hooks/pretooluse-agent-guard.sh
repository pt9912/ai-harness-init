#!/usr/bin/env bash
# pretooluse-agent-guard — verweigert jeden Agenten-Aufruf, den er mit erkennbarem
# ROLLEN-Typ und ohne run_in_background: false sieht. Was er entscheidet, ist die
# AUFRUFFORM vor dem Start; ueber den Ausgang des Laufs entscheidet er nicht mit —
# was er damit nicht deckt, steht in spec/spezifikation.md §5, Abweichung 5, Pruefschritt 3.
# Grund ist Telemetrie, nicht Sicherheit:
# gemessen am 2026-07-29 traegt die Antwort eines Hintergrund-Laufs weder
# Nutzungszaehler noch agentType — die Rollen-Achse bliebe leer und die
# Token-Bilanz eine Summe statt einer Rechnung (slice-060, MR-018, Modul 15).
#
# Reines bash + awk, KEIN node/jq (LH-QA-03): der Extraktor
# (harness/tools/extract-agent-call.awk) zieht genau zwei Felder aus der
# Hook-stdin-JSON. Fail-closed antworten FUENF Zweige, nicht jeder Eingang:
# fehlendes awk und fehlender Extraktor (UNBEWACHT, nicht unbewachbar),
# Parse-Zweifel (nur test/agent-guard.bats) und fehlender Typ (test/mutations/139)
# bei JEDEM Aufruf, fehlender Schalter (test/mutations/119) NUR bei Rollen-Typen.
#
# DIE ROLLEN-LISTE WIRD ABGELEITET, NICHT KOPIERT: ein Typ ist genau dann eine
# Rolle, wenn .claude/agents/<name>.md existiert. Damit gibt es keine vierte
# Kopie neben dem Verzeichnis, spec/spezifikation.md §5 und roleFromAgentType — und der Guard kann
# nicht gegen das Verzeichnis veralten, das er bewacht. Sensor: test/agent-guard.bats,
# "JEDER Typ in .claude/agents/ wird im Hintergrund abgelehnt" faehrt die Ableitung
# ueber jede Datei im Verzeichnis.
#
# NICHT betroffen: general-purpose, Explore, Plan und andere Nicht-Rollen-Typen.
# Sie duerfen im Hintergrund laufen; sie tragen ohnehin keine Rolle in den Span.
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
# Ueberschreibbar NUR fuer den Test: der bats-Lauf mountet das Repo read-only und
# kann deshalb keine Fixture-Rolle in .claude/agents/ legen. Ohne diese Naht
# waere die Zusage "die Liste wird ABGELEITET, nicht kopiert" unbelegt — eine
# hart notierte Namensliste bestuende jeden anderen Test. Sensor:
# test/agent-guard.bats, "eine ERFUNDENE Rolle im Fixture-Verzeichnis wird
# abgelehnt (Ableitung, keine Kopie)". Wer die Variable im
# Hook-Prozess setzen kann, kann auch settings.json aendern; der Guard ist ein
# Stolperdraht, keine Sandbox (ADR-0004).
agents_dir="${AGENT_GUARD_AGENTS_DIR:-$here/../agents}"

emit_deny() {
  # $1 = Grund (erscheint WOERTLICH beim Aufrufer — am 2026-07-29 gemessen).
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
  { emit_deny "Agent-Guard: Aufruf nicht eindeutig lesbar (Parse-Zweifel, fail-closed). Ein Rollen-Typ startet mit run_in_background: false."; exit 0; }

rib="$(sed -n '1p' <<<"$parsed")"
stype="$(sed -n '2p' <<<"$parsed")"

# Kein lesbarer Subagent-Typ -> verweigern. Der Hook haengt an "matcher": "Agent";
# was er sieht, IST ein Agenten-Aufruf, und ohne den Typ ist nicht entscheidbar, ob
# eine Rolle startet. Das dokumentierte Eingabe-Schema von Agent fuehrt
# subagent_type (docs/user/claude-hooks-referenz.md, Abschnitt Agent) — eine Payload
# ohne ihn ist keine bekannte Aufrufform, und Durchlassen hiesse raten. Zwoelf
# Zeilen tiefer steht dieselbe Antwort fuer den fehlenden Schalter. Sensor:
# test/agent-guard.bats, "guard: Agent-Aufruf ohne Subagent-Typ -> DENY
# (fail-closed)"; Dauer-Sensor test/mutations/139-agentguard-typ-failopen.sh.
[ "$stype" = "ABSENT" ] && { emit_deny "Agent-Guard: Aufruf ohne lesbaren subagent_type (fail-closed). Ohne Typ ist nicht entscheidbar, ob ein Rollen-Agent startet; ein Rollen-Typ startet mit run_in_background: false."; exit 0; }

# Kein Rollen-Typ -> Betriebsart ist frei. Der Zeichensatz von stype ist im
# Extraktor auf [A-Za-z0-9_:-] geprueft, ein Ausbruch aus agents_dir also nicht
# moeglich.
[ -f "$agents_dir/$stype.md" ] || exit 0

# Rolle im Vordergrund -> erlaubt. Alles andere, auch ein FEHLENDER Schalter,
# gilt als Hintergrund: gemessen ist Abwesenheit der Normalfall, nicht der
# Ausnahmefall, und der Standard ist Hintergrund.
[ "$rib" = "false" ] && exit 0

emit_deny "Rollen-Agent '$stype' muss im VORDERGRUND starten: run_in_background: false. Im Hintergrund traegt die Antwort keine Nutzungszaehler und kein agentType, die Rollen-Achse der Telemetrie bliebe leer (slice-060, MR-018). Fehlender Schalter gilt als Hintergrund."
exit 0
