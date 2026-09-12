**Vorgang:** slice-183
**Fund:** Der Verweis-Nachzug des Closure-Move (`make slice-mv SLICE=slice-183 TO=done`) schreibt in
eingefrorene Zeitdokumente. Gemessen vor dem Move, über der Präfix-Form, die das Werkzeug ersetzt:

```sh
git grep -l -- '../done/slice-183-ausloeser-der-wellenlosen-archivierung.md' \
  -- 'docs/plan/planning/done' | wc -l                                                    # 4
git grep -c -- '../done/slice-183-ausloeser-der-wellenlosen-archivierung.md' \
  -- 'docs/plan/planning/done' | awk -F: '{s+=$NF} END{print s}'                          # 13
git grep -l 'docs/plan/planning/in-progress/slice-183-ausloeser-der-wellenlosen-archivierung' \
  -- 'docs/reviews' | wc -l                                                               # 2
```

Keine Erwartungswerte. Vier Dateien unter `done/` — darunter ein geschlossener Welle-Plan und seine
Ergebnisnotiz — und zwei Rollen-Reports unter `docs/reviews/`, die ihren Gegenstand abschließend
beurteilt haben. Die Eingehend-Ausnahmeliste des Werkzeugs nimmt allein `.harness/baseline/**` aus;
dass `done/**` und `docs/reviews/**` darin stehen, ist seine dokumentierte Zusage
([`harness/README.md`](../../../../../../../harness/README.md)) und keine Panne — genau darum liegt
die Frage beim Architect und nicht beim bewegenden Lauf.

**Diese Closure hat die Frage nicht entschieden, und sie hatte auch keine Adresse:**
[`ADR-0041`](../../../../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
Festlegung 4 bindet den Vollzug der Archivierung an ihren Ausgang, und
[slice-216](../../../../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md)
schließt sie in seinem §1 ausdrücklich aus (*„dieselbe Berührung, anderer Gegenstand: Dort wird ein
Artefakt geschrieben, hier bricht ein Verweis"*). Der Eintrag steht damit über der Schwelle und
ohne Träger.
