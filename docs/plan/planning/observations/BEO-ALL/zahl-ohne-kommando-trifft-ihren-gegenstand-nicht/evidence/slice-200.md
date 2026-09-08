**Vorgang:** slice-200
**Fund:** Der Anlass-Absatz zu `make vendor-baseline` in
[`harness/README.md`](../../../../../../../harness/README.md) führt sich als Beleg ein (*„Der
Anlass ist gemessen, nicht vermutet"*) und sagt, *die zwei Quellen unterschieden sich in N
Dateien*. Die Zahl brauchte **zwei Korrekturen**, bevor sie ihren Gegenstand traf, und beide
Vorfassungen sahen belegt aus: Die erste stand ohne Kommando im Absatz, die zweite trug
`git grep -l '\.\./\.\./kurs/de/' <commit>^ -- '.harness/baseline/v6.5.0' | wc -l` — ein Kommando,
das eine **Link-Form** zählt und nicht die Differenz zweier Quellen; für den Satz war sie damit
eine Untergrenze und keine Größe. Der heutige Wert kommt aus
`git diff --name-only <commit>^ <commit> -- .harness/baseline/v6.5.0 | grep -v SHA256SUMS | wc -l`
und ist von zwei Rollen unabhängig nachgefahren.

**Die Weitergabe ist der eigentliche Weg:** Die Zahl entstand in einem Rollen-Bericht, wanderte
über eine Closure-Notiz in ein lebendes Artefakt und trug dabei jeweils ein Kommando bei sich —
nur eines, das eine andere Menge zählt. Beide Zwischenstationen sind Zeitdokumente und liegen
außerhalb des Geltungsbereichs von
[`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
und [`MR-051`](../../../../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
