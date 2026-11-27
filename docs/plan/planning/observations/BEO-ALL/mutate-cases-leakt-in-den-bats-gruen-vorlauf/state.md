**Stand:** offen

Zähler 1 (`ls evidence | wc -l`), unter der Schwelle: ein Teillauf mit
`verify: test-bats` kann seinen Grün-Vorlauf nicht abschließen, solange die
`MUTATE_CASES`-Umgebungsvariable in die hermetische bats-Suite wirkt
(`teillauf_fake`/`greift_main`-Fixtures in `test/mutate-driver.bats` lesen
dieselbe Variable) — der Fall selbst trägt seine Rot-Form am direkten
`BATS_TARGET`-Lauf, der Treiber liest „ohne Ergebnis“.
