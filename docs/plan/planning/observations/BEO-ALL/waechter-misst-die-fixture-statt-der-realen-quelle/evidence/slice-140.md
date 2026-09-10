**Vorgang:** slice-140
**Fund:** Der Integrations-Wächter der neuen Emit-Regel
(`TestTemplates_KeineKommentarHilfenImEmittiertenSatz`) läuft gegen `courseSet()`, eine
`fstest.MapFS`-Fixture, und nicht gegen den vendored Kurs-Satz: `.dockerignore` führt `.harness`
(Zeile 5), die Go-Test-Stufe sieht den realen Satz also nicht. `test/courseset-fixture.bats` hält
Dateibestand und Platzhalter-Pfad-Form der Fixture gegen den realen Satz — **keine Kommentare**.
Der zweite Sensor trägt es ebenfalls nicht: `make smoke` prüft in seinem einzigen Inhalts-Schritt
ein emittiertes `docs-check` mit `modules: [links, anchors]`, das Link-Ziele sieht und keinen
Kommentar-Inhalt — es bliebe grün, auch wenn die Funktion gar nicht verdrahtet wäre. Damit deckt
**kein** Lauf in `make gates` und keiner in CI die reale Wirkung; der Nachweis hängt an
`make full-smoke` außerhalb beider. Der Gegenstand ist Fremdtext, den
[`MR-008`](../../../../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
diesem Repo entzieht und der bei jedem Re-Baseline vollständig getauscht wird — die Fixture altert
also gegen etwas, das sich unabhängig von ihr bewegt. Eingetragen als Ausgang *weiter offen* von
§6 Risiko 2 dieses Slice.
