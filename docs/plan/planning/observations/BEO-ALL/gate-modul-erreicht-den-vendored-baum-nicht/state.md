**Stand:** offen

Kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) prüft die Klasse.
Die tragende Verengung ist **eine**, und sie ist gemessen: `codepaths.roots` vergleicht
Präfix-**Zeichenketten** (`roots: [spec, docs, harness]`), und `.harness` beginnt nicht mit
`harness` — geprüft wird die Quelldatei sehr wohl, unerkannt bleibt das **Ziel**. Die in
`observation.md` daneben genannte Scan-Ausnahme trägt nicht: Ein erfundener Pfad **ohne**
Vendoring-Segment bleibt ebenso stumm und färbt rot, sobald die Wurzel aufgenommen ist. `links`
sieht nur die Link-Form, und `make comment-claims` nimmt jede Markdown-Datei dauerhaft aus seinem
Prüfbereich.

Der Ausgang ist als
[slice-202](../../../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
geschnitten: die vierte Wurzel plus je Klasse eine eigene, gemessene Ausnahme. Bis dahin steht die
Grenze benannt in [`harness/README.md`](../../../../../../harness/README.md) §Sensors, und Träger
ist der Lauf, der den Pfad schreibt.
