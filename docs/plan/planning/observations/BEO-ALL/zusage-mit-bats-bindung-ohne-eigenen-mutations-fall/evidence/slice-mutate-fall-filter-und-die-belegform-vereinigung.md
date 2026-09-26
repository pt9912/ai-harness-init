**Vorgang:** slice-mutate-fall-filter-und-die-belegform-vereinigung
**Fund:** Der Wächter `make mutate` ist gelistet (Fälle 263, 264 und die neuen 453 bis 458), und Zusagen des Filters hingen allein an
`bats`-Assertionen in `test/mutate-driver.bats`, ohne Fall in `test/mutations/`: der Pfad-Zweig des Filters (Review R-3, LOW),
die Zeile `TEILLAUF … kein Beleg` bei einem Befund (R-4, LOW) und die Zähne für *leer*, *doppelt* und *Filter wählt alle* (R-7, INFO).
Die Ersatz-Mutationen zu R-3 und R-4 ließen die Suite grün; beide Zusagen sind mit `219fc551` durch `bats`-Tests gebunden, und der
Verifier sah sie rot (m6, m7). **Ungelistet bleiben** *leer*, *doppelt*, *Filter wählt alle* und der Pfad-Zweig: sie tragen weiter
keinen Fall in `test/mutations/` (`docs/reviews/2026-09-26-verify-slice-mutate-fall-filter-und-die-belegform-vereinigung.md`,
V-5 für *Filter wählt alle*). Der Ausgang `geplant` der Beobachtung gilt der Instanz `sync`; diese Instanz deckt er nicht.
