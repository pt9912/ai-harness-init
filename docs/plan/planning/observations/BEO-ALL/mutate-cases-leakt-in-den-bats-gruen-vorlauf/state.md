**Stand:** geplant — `slice-mutate-cases-leakt-nicht-am-teillauf` (liegt in `next/`)

Zähler 3 (`ls evidence | wc -l`), an der Schwelle: ein Teillauf mit
`verify: test-bats` kann seinen Grün-Vorlauf nicht abschließen, solange die
`MUTATE_CASES`-Umgebungsvariable in die hermetische bats-Suite wirkt
(`teillauf_fake`/`greift_main`-Fixtures in `test/mutate-driver.bats` lesen
dieselbe Variable) — der Fall selbst trägt seine Rot-Form am direkten
`BATS_TARGET`-Lauf, der Treiber liest „ohne Ergebnis“. Zweites Auftreten im
Vorgang `slice-stamp-records-konsum-v1` (Verify-Befund B-1): der
dokumentierte Teillauf-Aufruf `MUTATE_CASES='<fälle>'` selbst bricht im
Grün-Vorlauf an demselben Wrapper-Fall; Beleg und Folge-Slice
`slice-mutate-cases-leakt-nicht-am-teillauf` stehen in der Evidence-Datei.
