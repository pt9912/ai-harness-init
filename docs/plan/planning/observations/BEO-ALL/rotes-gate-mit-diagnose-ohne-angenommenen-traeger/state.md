**Stand:** offen

Das Instrument besteht und ist benannt: `v6.5.0` · `regelwerk/modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln lässt einen Slice bei rotem Gate nur mit dokumentiertem Carveout
nach `done/`. Was fehlt, ist der Schritt, der zwischen Diagnose und Closure prüft, **ob** einer
liegt — kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) liest
Carveouts, und `make mutate` kennt dafür keine Fehlschlag-Form. Für den Fund selbst hat die
Closure von `slice-193` den Träger angelegt: `CO-006`.
