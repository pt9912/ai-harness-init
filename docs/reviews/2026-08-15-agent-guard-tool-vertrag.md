# Der Agent-Guard gegen den Tool-Vertrag — die Messung

**Rolle:** Hauptkontext — keine der sechs Rollen, denn keine ist startbar (§1).
**Datum:** 2026-08-15. **Autor:** ai-harness-init-Team (pt9912).

**Gegenstand:** vier Messungen am `PreToolUse`-Agent-Guard und am Eingabe-Vertrag des
`Agent`-Werkzeugs, die Rechnung, was der Ausfall an Telemetrie wirklich kostet, und der
Optionsraum, der daraus folgt. Zeitdokument: jede Zahl gilt an ihrem Datum.

**Was hier NICHT steht: eine Entscheidung.** Der Guard, `spec/spezifikation.md` §5, `MR-018`
und die Carveout-Ablage bleiben unberührt. Eine Senkung der Durchsetzung ist eine ADR
(`AGENTS.md` §3.5), und die schreibt der Architect (§3.8) — nicht dieser Text.

---

## 1. Der Guard weist jeden Rollen-Typ ab

Probe am 2026-08-15: `subagent_type: architect`, minimaler Prompt, kein weiteres Feld. Die
Antwort erscheint wörtlich beim Aufrufer:

> Rollen-Agent 'architect' muss im VORDERGRUND starten: run_in_background: false. Im
> Hintergrund traegt die Antwort keine Nutzungszaehler und kein agentType, die Rollen-Achse
> der Telemetrie bliebe leer (slice-060, MR-018). Fehlender Schalter gilt als Hintergrund.

Das ist der **letzte** Zweig von `.claude/hooks/pretooluse-agent-guard.sh`, nicht der
Typ-Zweig. Der Extraktor `harness/tools/extract-agent-call.awk` hat `architect` gelesen, und
`.claude/agents/architect.md` existiert — sonst wäre der Aufruf zwei Zeilen früher mit einem
anderen Text gefallen. Gefehlt hat allein der Schalter.

Betroffen sind alle sechs Rollen. `general-purpose`, `Explore` und `Plan` laufen unverändert:
der Guard prüft die Betriebsart erst, nachdem der Typ sich als Rolle erwiesen hat.

## 2. Der Schalter ist nicht sendbar

Das Eingabe-Schema des `Agent`-Werkzeugs führt am 2026-08-15 `prompt`, `description`,
`subagent_type`, `model` und `isolation` — **kein `run_in_background`**, und es lässt keine
zusätzlichen Felder zu. Die vendored Werkzeug-Doku `docs/user/claude-hooks-referenz.md` sagt
dasselbe: ihre Agent-Eingabetabelle nennt vier Felder, keines davon der Schalter; und sie hält
fest, dass Subagenten **ab v2.1.198 standardmäßig im Hintergrund** laufen, ein weggelassener
Schalter also `async_launched` erzeugt. Der Start eines erlaubten Typs meldet entsprechend
„Async agent launched".

Der Kontrast zur eigenen Messreihe ist der Kern: am 2026-07-29 trug `tool_input` über vier
echte Aufrufe die Schlüssel `subagent_type`, `prompt`, `description` **und
`run_in_background`** (`docs/reviews/2026-08-02-span-schema-messreihen.md` §1). Das Feld war
messbar, als der Guard gebaut wurde. Es ist aus dem Vertrag verschwunden, nicht aus der
Zustellung.

Damit ist der Guard nicht verletzt, sondern **unerfüllbar**: er verlangt eine Aufrufform, die
das Werkzeug nicht mehr anbietet. Sein Verhalten ist korrekt fail-closed; falsch geworden ist
seine Bedingung.

## 3. Was ein Hintergrund-Lauf trägt — die Gegenprobe

Ein erlaubter Nicht-Rollen-Typ (`general-purpose`, Modell-Alias `haiku`) wurde am 2026-08-15
mit einer trivialen Aufgabe gestartet. Sein `Agent`-Span (`15:38:17Z`) trägt:

`model_version: claude-haiku-4-5-20251001` · `result_bytes: 419` · `duration_ms: 6` ·
`status: ok`

und **nicht**: `spawned_role`, die vier `usage`-Zähler, `totalTokens`, `totalDurationMs`,
`totalToolUseCount`.

Die sechs Millisekunden sind die Dauer des **Aufrufs**, nicht des Laufs — der Subagent lief
1.968 ms. Das ist dasselbe Muster, das am 2026-07-29 mit 3 ms bei 4.184 ms Laufzeit gemessen
wurde. Der Satz im Deny-Text des Guards ist also empirisch wahr: im Hintergrund trägt die
Antwort weder Zähler noch `agentType`.

## 4. Der abgewiesene Aufruf hinterlässt keinen Span

Am 2026-08-15 steht im Span-Bestand **kein** `Agent`-Span aus der abgewiesenen Probe — weder
als `PostToolUse` noch als `PostToolUseFailure`; der einzige `Agent`-Span des Tages ist der
erlaubte Lauf aus §3. Ein `PreToolUse`-Deny ist im Bestand unsichtbar: die Blockade lässt sich
nicht zählen, nicht datieren und nicht auf ihren Grund zurückführen. Es ist genau die Lücke,
die `slice-074` benennt.

## 5. Was der Ausfall kostet — und was nicht

**Die Rollen-Achse bleibt.** `agent_type` und `agent_role` stammen aus der Hook-Payload
*innerhalb* des Subagenten (`internal/span/span.go`, Zeilen 86–87) und sind von der
Betriebsart unabhängig. Der Bestand belegt es: gewöhnliche `Bash`-Spans aus Subagenten-Läufen
tragen `agent_type: architect`. Ein Hintergrund-Lauf füllt diese Achse also weiter.

**Verloren ist genau ein Ding: das Kosten-Aggregat des `Agent`-Aufrufs** — `spawned_role`
zusammen mit den vier `usage`-Zählern und den drei Summen. Daran hängt die Auswertung:
`internal/report/report.go` zählt in Zeile 136 jeden `Agent`-Span als Lauf und kehrt eine Zeile
später zurück, sobald Eingabe- und Ausgabe-Zähler beide fehlen. Bei
durchgehendem Hintergrund-Betrieb wächst `AgentLaeufe`, `MitZaehlern` bleibt 0, und die
Token-Bilanz je Rolle hat keinen einzigen Eingang mehr. Die Abdeckungszahl, die der Bericht
mitführt, sagt das dann von selbst — sie steht auf 0 von N.

**Ein Ersatz-Träger existiert unter den Hook-Ereignissen nicht.** `SubagentStop` erhält
`stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path` und
`last_assistant_message` — die Rolle also sicher, **keine** `usage`. Die Zähler eines
Hintergrund-Laufs stehen nur noch im Subagenten-Transkript, einer Fremddatei, die den Prompt
enthält.

**Der Rückkanal an den Aufrufer trägt Zahlen, aber nicht dort, wo ein Sensor liest.** Die
Fertigmeldung des Laufs aus §3 nannte 17.620 Subagenten-Token, 0 Werkzeug-Aufrufe und 1.968 ms
— eine Summe ohne Aufschlüsselung nach Typ und ohne Rolle, zugestellt in den Kontext des
Aufrufers, nicht an einen Hook. Ein Sensor, der sie liest, existiert nicht.

## 6. Der Optionsraum

Drei Wege sind gangbar; dieser Text wählt keinen.

**A — Die Schalter-Forderung fällt, der Verlust wird geführt.** Der Guard verlangt den
Schalter nicht mehr; seine übrigen vier fail-closed-Zweige (fehlendes `awk`, fehlender
Extraktor, Parse-Zweifel, fehlender Typ) bleiben unberührt. Die Rollen laufen sofort wieder.
Der Preis ist die Token-Achse aus §5, und er gehört als Carveout geführt — die Klasse, für die
`CO-001` den Präzedenzfall setzt: *eine technische Werkzeuggrenze, kein „noch nicht
geschafft"*, mit Geltungsbereich, Begründung und Auflösungs-Trigger. Der Trigger ist benennbar:
ein Tool-Vertrag, der wieder eine Vordergrund-Form anbietet, oder ein Hook-Ereignis, das die
Zähler trägt.

**B — Der Träger wechselt auf `SubagentStop`.** Das Ereignis trägt die Rolle unabhängig von der
Betriebsart; die Zähler wären aus `agent_transcript_path` zu lesen. Das ist ein neuer Parser in
`bash` + `awk` über ein undokumentiertes Format — und er läse eine Datei, die den Prompt
enthält, gegen die `ADR-0011` Festlegung 2 steht (*kein Byte fremden Inhalts*). Eine
Positiv-Liste könnte die Linie halten, aber der Weg löst den Blocker erst an seinem Ende.

**C — Der Guard bleibt, wie er ist.** Dann bleibt die Rollen-Trennung dieses Repos
unbenutzbar: Planner, Architect, Implementer, Reviewer, Verifier und Validator sind nicht
startbar, und jede Arbeit, die eine dieser Rollen verlangt, steht.

**Die Reihenfolge ist das eigentliche Problem.** Der Weg in A wie in B ist eine Änderung an der
Durchsetzung, und `AGENTS.md` §3.5 verlangt dafür eine ADR; ADRs schreibt der Architect (§3.8),
den derselbe Guard blockiert. Die Schleife lässt sich nicht von innen aufschneiden — der
Eintritt ist eine Auftraggeber-Entscheidung, die Klasse, die `MR-015` regelt.
