# Gate-Modul erreicht den vendored Baum nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein **lebendes** Artefakt nennt einen Pfad in den vendored Baum als Inline-Code, und kein Modul des
Doku-Gates prüft ihn auf Existenz — der Pfad ist nach einem Tag-Tausch tot und bleibt dauerhaft
unsichtbar. Zwei Verengungen fallen zusammen: `codepaths` führt `roots: [spec, docs, harness]` und
erreicht damit weder die Projektwurzel noch `.harness/`, und `scan.ignore` nimmt
`.harness/baseline/**` als Ziel ohnehin aus. Die Link-Form derselben Adresse fällt dagegen an
`links` auf und färbt rot. Die Sichtbarkeit hängt damit an der Markdown-Klammer und nicht an der
Eigenschaft der Adresse — dieselbe tote Adresse ist laut oder stumm, je nachdem, ob jemand sie
verlinkt hat.
