**Stand:** offen

Kein Sensor meldet die Klasse. `make span-report` rechnet eine Token-Bilanz je Rolle und
urteilt nicht über die Werkzeug-Mischung eines Stroms; `make hook-overhead` misst den
Aufschlag je Tool-Call und nicht ihre Zahl. Beide lesen den Bestand ohnehin erst, nachdem
der Lauf vorbei ist — die Beobachtung entsteht **während** er fährt. Träger ist bis auf
Weiteres, wer dem Lauf zusieht.

## Die Bezeichnung trägt eine Wahl, die der Lauf nicht hat

**Der Name dieses Eintrags ist die Beschreibung des Verhaltens, nicht seine Diagnose.**
*„gepollt statt abgewartet"* unterstellt ein verfügbares Warte-Mittel. Ein Subagent hat
keines: Keine der sechs Rollen-Definitionen führt eines.

```sh
for a in .claude/agents/*.md; do printf '%-12s %s\n' "$(basename "$a" .md)" "$(grep -m1 -iE '^tools:' "$a")"; done
grep -ilE 'BashOutput|TaskOutput|Monitor' .claude/agents/*.md || echo keine
```

Alle sechs deklarieren `Read, Write, [Edit,] Bash` — kein `BashOutput`, kein `TaskOutput`,
kein `Monitor`. Wer einen Hintergrund-Lauf startet, hat damit zwei Möglichkeiten: die
Ausgabe-Datei mit `Read` nachlesen, oder den Zug beenden. **Beides ist im Bestand belegt**, und
die Aufforderung *„warte statt zu pollen"* führt zum zweiten: Warten ist für einen Lauf ohne
Warte-Werkzeug keine Handlung, sondern das Ende seines Zugs.

**Die Asymmetrie ist gemessen, nicht erschlossen.** Der Haupt-Kontext hat ein Warte-Werkzeug
und benutzt es; die Rollen-Ströme haben keines (**keine Erwartungswerte** — der Bestand ist
gitignored, maschinenlokal und seit dem 2026-09-08 auf drei Tage beschnitten):

```sh
cat .harness/state/spans/*.jsonl | grep -oE '"tool":"(BashOutput|TaskOutput|Monitor)"' | sort | uniq -c
#   1 "tool":"Monitor"   -- und dieser eine Span liegt in einem Strom mit LEEREM agent_role
for f in .harness/state/spans/*.jsonl; do
  grep -qE '"agent_role":"(planner|architect|implementer|reviewer|verifier|validator)"' "$f" && echo rolle || echo haupt
done | sort | uniq -c   # 105 rolle, 2 haupt
```

**Die Ursachenkette, so wie sie sich misst:** Die Zeit-Vorgabe des Bash-Werkzeugs schneidet
einen langen Lauf ab → der Lauf weicht in den Hintergrund aus → dort hat er kein
Warte-Werkzeug → Polling oder Zug-Ende. Der Hebel liegt am **ersten** Glied, nicht am
dritten: Ein ausdrücklich gesetzter `timeout` macht den Hintergrund für einen Lauf
überflüssig, der innerhalb der Obergrenze bleibt. Für Läufe darüber — `make mutate` liegt dort
— bleibt das Zug-Ende, und es ist der richtige Ausgang, solange jemand weckt.

**Der Eintrag verliert dadurch seinen Gegenstand nicht.** Er zählt dasselbe Verhalten wie
zuvor; nur seine Ursache ist eine andere, als die Bezeichnung nahelegt. `observation.md` ist
ab Anlage unveränderlich, die Bezeichnung steht damit fest — wer sie für die Diagnose hält,
liest den Namen statt dieses Abschnitts.

## Zwei Hebel, beide ohne benannte schreibende Rolle

- **Ein ausdrücklich gesetzter `timeout` am langen Lauf** — der Ort dafür wäre ein
  Rollen-Anweisungssatz unter `.claude/commands/`. Der gehört nach
  [`ADR-0028`](../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) der
  **ausführenden** Rolle, nicht dem Planner.
- **Ein Warte-Werkzeug in der `tools:`-Zeile der Rollen-Definitionen** — `.claude/agents/*.md`
  nimmt dieselbe ADR **ausdrücklich aus**, und keine andere Quelle benennt eine schreibende
  Rolle. Die Frage ist damit offen und **hier nicht entschieden**.

**Kein Ausgang ist zugewiesen.** Der Zähler steht unter der Schwelle
(`ls evidence/*.md | wc -l`), und dort ist `offen` der Normalzustand, kein Ausgang; die
Zuweisung ist Sache des Lese-Schritts. Dass die Ursache benannt ist, nimmt ihm nichts vorweg.
