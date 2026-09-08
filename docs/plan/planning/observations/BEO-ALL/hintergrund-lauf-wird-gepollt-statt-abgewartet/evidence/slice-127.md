**Vorgang:** slice-127
**Fund:** Der Behebungs-Lauf dieses Slice (Strom mit `"commit":"fc92aca569a9"`, Rolle
`implementer`) führt **571** Lese-Zugriffe, davon **559** auf Hintergrund-Ausgabedateien unter
`/tasks/<id>.output` — **97,9 %**. Daneben stehen 364 `Bash`- und **10** `Edit`-Aufrufe: die
Arbeit am Slice ist zweistellig, das Nachlesen dreistellig. Gegenüber dem ersten Beleg
(`slice-123`: 123 von 151, 81 %) ist das dieselbe Form in ausgeprägterer Gestalt — genau die, die
[`observation.md`](../observation.md) unter *Benannt, nicht gezählt* für diesen Slice vorwegnahm
und mit dem Abschluss hier zum Beleg wird.

**Der Befund bestätigt die Ursachenkette in [`state.md`](../state.md), nicht die Bezeichnung
dieses Eintrags.** Ein Warte-Werkzeug stand dem Lauf auch hier nicht zur Verfügung: über den
gesamten verbliebenen Bestand kommt `BashOutput` und `TaskOutput` **null** Mal vor, `Monitor`
zweimal — und beide Vorkommen liegen im Strom mit leerem `agent_role`, also im Haupt-Kontext, nicht
in einem der 106 Rollen-Ströme. Der Lauf hat damit nicht das falsche Mittel gewählt, sondern
zwischen Nachlesen und Zug-Ende entschieden.

**Messung, nicht Erwartungswert** — der Span-Bestand ist gitignored, maschinenlokal und seit dem
2026-09-08 auf drei Tage beschnitten; auf einem anderen Checkout gibt es ihn nicht
([`spec/spezifikation.md`](../../../../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5). Stand 2026-09-08, aus `.harness/state/spans/`:

```sh
f=$(grep -l '"commit":"fc92aca569a9"' *.jsonl | head -1)
grep -oE '"tool":"[A-Za-z]*"' "$f" | sort | uniq -c | sort -rn   # 571 Read, 364 Bash, 10 Edit
grep '"tool":"Read"' "$f" | grep -c '/tasks/[a-z0-9]*\.output'   # 559
grep -h -oE '"tool":"(BashOutput|TaskOutput|Monitor)"' *.jsonl | sort | uniq -c   # nur: 2 Monitor
grep -l '"tool":"Monitor"' *.jsonl | while read -r m; do
  grep -oE '"agent_role":"[a-z]*"' "$m" | sort -u; done            # "agent_role":""
```
