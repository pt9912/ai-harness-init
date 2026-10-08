**Stand:** offen

Die Kennung `slice-211-codepaths-im-emittierten-doc-gate` hat geliefert, was sie zusagte, und liegt
in `done/`; der Eintrag steht über der Schwelle und erhält seinen Ausgang beim Lese-Schritt der
Closure von `welle-emittiertes-doc-gate`.

**Die Inline-Pfad-Hälfte hat einen Wächter.** Das Doku-Gate jedes gebootstrappten Ziels fährt
`codepaths` (`roots: [spec, docs, harness]`, `exempt-paths: ["docs/reviews/**"]`); ein im
emittierten Text genannter Ort, den das frische Ziel nicht trägt, färbt es mit `codepath-missing`
rot. Gehalten vom Zahn in `make full-smoke` und von den Mutations-Fällen `573`–`578`.

**Die Aussagen-Hälfte hat keinen.** Ein emittierter Text, der eine Eigenschaft des Ziels zusagt,
ohne einen Pfad zu nennen, liegt in keinem Prüfbereich; das Kriterium steht in
[`ADR-0037`](../../../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) Festlegung 1, und
dessen §Fitness Function benennt die Lücke selbst.
