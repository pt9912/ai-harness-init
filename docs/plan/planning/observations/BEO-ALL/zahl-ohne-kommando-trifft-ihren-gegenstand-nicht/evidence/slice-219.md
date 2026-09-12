**Vorgang:** slice-219
**Fund:** Die Commit-Message des Umsetzungs-Commits sagt *„Sieben neue Go-Tests in
vorschau_test.go"*; gemessen sind es **sechs** —
`git show f9ef00e2 -- internal/archive/vorschau_test.go | grep -c '^+func Test'` → 6. Die Zahl
stand ohne das Kommando, das sie liefert, und hat von Anfang an falsch gezählt; gefunden hat sie
das Review, das genau dieses Kommando fuhr.

Der Locus unterscheidet diesen Beleg von den übrigen des Eintrags: Die Zahl steht in einer
**Commit-Message**, nicht in einem lebenden Markdown-Artefakt, und gebunden ist sie darum von
[`MR-051`](../../../../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 1 statt von
[`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1. Die Fehlform ist dieselbe, die dieser Eintrag führt, und nicht die des Nachbars
[`zahl-neben-nie-gefahrenem-kommando`](../../zahl-neben-nie-gefahrenem-kommando/observation.md):
Dort steht ein Kommando neben der Zahl und ist nie gefahren worden, hier steht überhaupt keines.

Korrigierbar ist der Fund nicht — eine Commit-Message ist ab dem Commit unveränderlich, und ein
`rebase` über eine gepushte Historie wäre der teurere Fehler. Ein Wächter besteht auch hier nicht:
Der PreToolUse-Zusatz-Hook prüft die **Anwesenheit** einer Traceability-Kennung, nicht die Wahrheit
einer Zahl, und er sieht ohnehin nur den per `-F` übergebenen Datei-Weg.
