# Messung ersetzt die Zielplattform durch ihren Git-Filter

**Sub-Area:** `*` (gesamtes Repo)

Eine Zusage über eine Zielplattform — hier Windows — wird an einem Ersatz belegt, der dieselbe
Wirkung auf die Bytes hat: der Smudge-Filter von git unter Linux, angestoßen durch
`-c core.autocrlf=true`. Was nur die Plattform selbst zeigt, bleibt ungemessen: eine andere
Konfigurationsebene für `core.autocrlf`, `core.symlinks`, das Ausführungsbit, ein Windows-`make`.
Die Fehlerrichtung ist *die Plattform ist gedeckt*, wo gedeckt ist, was git mit den Bytes tut; die
Grenze der Messmethode steht am Anforderungs-Eintrag
([`LH-QA-04`](../../../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)), und jede Stufe, die
so misst, erbt sie.
