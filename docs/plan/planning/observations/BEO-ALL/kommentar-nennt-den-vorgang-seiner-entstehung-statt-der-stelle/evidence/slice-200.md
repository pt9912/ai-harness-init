**Vorgang:** slice-200
**Fund:** Zwei Stellen des neuen Vendoring-Zweigs sprachen über den Vorgang ihrer Entstehung statt
über die Stelle. Der Kommentar über
`TestSubkommandoRouting_VendorBaselineFaelltNichtInDenInitPfad` nannte das Gegenbeispiel *„Ohne den
`case` wäre der Name in run() ein Positionsargument, und der Init-Pfad schriebe in das
Arbeitsverzeichnis"* — verworfene Alternative im Konjunktiv, und gemessen falsch: Über einer Kopie
ohne den `case` bleibt der Go-Satz vollständig grün, weil die Sperre in `run()` jedes
Positionsargument gleich beantwortet. Und drei Stellen — `cmd/ai-harness-init/vendor_baseline.go`,
`Makefile`, [`harness/README.md`](../../../../../../../harness/README.md) — führten *„hatte bislang
genau EINEN Aufrufer … dieser Zweig ist der zweite"* im Perfekt über einen abgelösten Zustand,
während der Zustand am Baum *zwei Aufrufer* lautet. Beide Funde stammen aus dem Review; kein Sensor
sieht sie, `make comment-claims` prüft die Existenz eines genannten Sensors und nimmt `Makefile`
und jede Markdown-Datei dauerhaft aus seinem Prüfbereich.
