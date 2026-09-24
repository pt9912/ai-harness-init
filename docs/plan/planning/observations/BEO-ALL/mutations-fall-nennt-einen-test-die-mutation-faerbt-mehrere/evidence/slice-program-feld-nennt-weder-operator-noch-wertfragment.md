**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Bei den Fällen 404 bis 407 färbt die Mutation zwei Testfunktionen rot, das `# expect:`
nennt eine, und die Gegenprobe wird grün erst, wenn in beiden die geschützten Zeilen fehlen; für
`(`, `{`, `;`, `'` und Backtick aus `unsureValueChars` deckt ein Fragments-Subtest dasselbe Zeichen
mit. Beleg: Gegenprobe-Bericht des Verifiers,
`docs/reviews/2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-gegenprobe.md`,
Tabelle *Fälle 404 bis 408* und INFO-1.
