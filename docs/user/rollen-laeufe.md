# Rollen-Läufe — wie Rollen-Arbeit gestartet wird und wo die Regel endet

**Zweck:** Die geltende Konvention für Läufe, die einer Harness-Rolle zugeordnet sind
(Planner, Architect, Implementer, Reviewer, Verifier, Validator). Diese Datei liegt unter
`docs/user/` und trägt dort den Rang 6 der Source Precedence. Sie führt die Regel und ihre
Grenzen, keine Messung und keine Chronik: was ein Werkzeug-Verhalten belegt, steht in den
Zeitdokumenten unter `docs/reviews/`, nicht hier.

Warum diese Konvention besteht: die Erfassungsschicht schreibt je Werkzeug-Aufruf einen Span
(Schema: [`spec/spezifikation.md` §5](../../spec/spezifikation.md#5-metriken-und-tracing-felder)),
und die Token-Bilanz je Rolle ([`make span-report`](../../harness/README.md#werkzeuge-kein-gate))
liest die Rolle aus diesem Span. Die Rolle steht nur dann darin, wenn der Lauf **unter dem
Rollen-Typ** gestartet wurde. Die Regel gehört deshalb hierher und in kein Gedächtnis einer
einzelnen Sitzung.

## START-KONVENTION für Rollen-Läufe

Wer Rollen-Arbeit an einen Subagenten gibt, startet ihn **unter seinem Rollen-Typ, per
@-Erwähnung**. Das entscheidet, **welche** Rolle läuft. Die kanonischen Typ-Namen sind die
sechs Rollen-Namen, klein geschrieben; sie stehen in
[`spec/spezifikation.md` §5](../../spec/spezifikation.md#5-metriken-und-tracing-felder), nicht
hier.

- **Der Grund für die @-Erwähnung ist eine fremde Zusage, kein Repo-Beleg.** Die
  Subagenten-Seite der Herstellerseite (`/docs/de/sub-agents`) nennt die @-Erwähnung als den
  Weg, der die Ausführung *garantiert*, während natürliche Sprache die Delegation dem Modell
  überlässt. Die vendored [Hooks-Referenz](claude-hooks-referenz.md) verweist in ihrem
  `Agent`-Eintrag nur auf diese Seite und trägt den Satz nicht. Im Repo liegt nichts, woran
  man ihn nachprüft.
- **Die Betriebsart ist nicht zu wählen.** Ein Rollen-Lauf startet im Hintergrund; das
  Werkzeug führt den Hintergrund als Standard
  ([Hooks-Referenz](claude-hooks-referenz.md)). Die Konvention hat damit **eine** Bedingung:
  den Typ. Der Agent-Guard prüft die Lesbarkeit der Aufrufform, nicht die Betriebsart.
- **Wer die Rolle nicht anfordert, bekommt `general-purpose`.** Das Feld `agent_role` bleibt
  dann leer und heißt *unbekannt*, nicht *ohne Rolle*; der Lauf fällt in den Sammelposten der
  Token-Bilanz.

## Dass Rollen-Arbeit als Rolle läuft

Oben steht, **wie** ein Rollen-Lauf startet, wenn einer startet; hier steht, **dass** einer
startet. Arbeit, die einer Harness-Rolle zugeordnet ist, läuft **unter dem Rollen-Typ**. Der
Haupt-Kontext orchestriert und ist der **Sammelposten**.

- **Diese Regel trägt keinen Wächter.** Sie ist nicht aus Aufwand, sondern konstruktiv nicht
  mechanisch durchsetzbar, und sie kann gebrochen werden, ohne dass irgendetwas rot wird.
- **Sichtbar wird ein Bruch nur teilweise.** Wer Rollen-Arbeit delegiert, aber nicht unter dem
  Rollen-Typ, hebt den Anteil des Sammelpostens an der Token-Bilanz, soweit der Lauf Zähler
  trägt. Wer den Schritt selbst im Haupt-Kontext tut, erzeugt keinen `Agent`-Span und steht
  nirgends: ein kleiner Anteil heißt darum nicht, dass die Regel gelebt wird. Was die
  Berichtsgröße festlegt, steht in
  [`spec/spezifikation.md` §5](../../spec/spezifikation.md#5-metriken-und-tracing-felder).
