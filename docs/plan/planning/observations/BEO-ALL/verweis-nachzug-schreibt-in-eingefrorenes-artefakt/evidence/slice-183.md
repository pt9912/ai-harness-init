**Vorgang:** slice-183
**Fund:** Der Verweis-Nachzug des Closure-Move (`make slice-mv SLICE=slice-183 TO=done`) schreibt in
eingefrorene Zeitdokumente. Der Nachzug-Commit `bf842e61` ist sein eigener Beleg — sechs seiner zehn
Dateien liegen in den zwei Bäumen, die [`AGENTS.md`](../../../../../../../AGENTS.md) §3.4 einfriert:

```sh
git show --numstat --format= bf842e61 -- 'docs/plan/planning/done' 'docs/reviews' | wc -l   # 6
git show --numstat --format= bf842e61 -- 'docs/plan/planning/done' 'docs/reviews' \
  | awk '{s+=$1} END{print s}'                                                              # 16
```

Vier Dateien unter `done/` — darunter ein geschlossener Welle-Plan und seine Ergebnisnotiz — und
zwei Rollen-Reports unter `docs/reviews/`, die ihren Gegenstand abschließend beurteilt haben.
16 Zeilen sind ersetzt. Die Eingehend-Ausnahmeliste des Werkzeugs nimmt allein
`.harness/baseline/**` aus; dass `done/**` und `docs/reviews/**` darin stehen, ist seine
dokumentierte Zusage ([`harness/README.md`](../../../../../../../harness/README.md)) und keine
Panne — genau darum liegt die Frage beim Architect und nicht beim bewegenden Lauf.

**Diese Closure hat die Frage nicht entschieden, und sie hatte auch keine Adresse:**
[`ADR-0041`](../../../../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
Festlegung 4 bindet den Vollzug der Archivierung an ihren Ausgang, und
[slice-216](../../../../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md)
schließt sie in seinem §1 ausdrücklich aus (*„dieselbe Berührung, anderer Gegenstand: Dort wird ein
Artefakt geschrieben, hier bricht ein Verweis"*). Der Eintrag steht damit über der Schwelle und
ohne Träger.

**Warum hier ein Commit-Operand steht und kein Pfad-Literal:** Die erste Fassung dieses Belegs maß
mit `git grep` über der Präfix-Form `../in-progress/…` — derselbe Nachzug hat diese Operanden im
Beleg selbst auf `../done/…` umgeschrieben, und eine der drei Zeilen lieferte danach `0` statt `2`.
Das ist die Nachbarklasse
[`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../../verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md)
und hat im selben Vorgang ihren eigenen Beleg.
