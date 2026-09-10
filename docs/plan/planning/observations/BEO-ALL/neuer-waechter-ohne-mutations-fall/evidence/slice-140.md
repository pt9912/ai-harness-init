**Vorgang:** slice-140
**Fund:** Der Slice legt mit `StripCommentHints` eine Regel samt vier benannten Hilfs-Bezeichnern
an und listet drei davon in keinem Fall unter `test/mutations/`:
`grep -l dcheckIgnoreMarkerPattern test/mutations/*.sh`, dasselbe für `backtickSpanPattern` und
für `unmaskQuotedCommentSyntax` sind je leer, während `grep -c` derselben Namen in
`internal/emit/templates.go` je nicht null liefert. Getroffen ist ausgerechnet
`dcheckIgnoreMarkerPattern` — die eine Ausnahme, die der Set-Index des Kurses für Schritt 5
ausdrücklich vorschreibt: verlöre sie ihre Zähne, fiele jeder `d-check:ignore`-Marker aus dem
emittierten Baum, und `make mutate` spräche nicht davon. Die Klasse trat viermal über die sieben
Review-Runden auf, jedes Mal an einer anderen Stelle derselben Funktionsfamilie; zwei Fälle sind
im Lauf entstanden (`291`/`292`), zwei weitere nachgereicht (`293`/`294`), und der Rest blieb.
**Ein Vorgang zählt einmal** — diese eine Datei, nicht vier.
