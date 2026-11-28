**Vorgang:** slice-release-bau-dockerlos-v1
**Fund:** Review Befund F-2: der lokale Teillauf
`make mutate MUTATE_CASES='836-release-bau-ldflags-injektion-entzogen'`
bricht im Grün-Vorlauf an `test/mutate-driver.bats` Fall 427
(`MUTATE_CASES nennt einen unbekannten Fall` über der 427-Fixture), noch vor
der Rot-Messung — die `MUTATE_CASES`-Umgebung der Auswahl wirkt in die
hermetische bats-Suite. Dritte Instanz der Klasse; die Rot-Messung des Falls
trug der direkte `BATS_TARGET`-Lauf. Beleg: Review-Report
`docs/reviews/2026-11-28-slice-release-bau-dockerlos-v1.md` (F-2).
