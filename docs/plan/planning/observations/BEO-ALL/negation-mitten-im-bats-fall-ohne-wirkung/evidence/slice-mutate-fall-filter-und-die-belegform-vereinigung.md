**Vorgang:** slice-mutate-fall-filter-und-die-belegform-vereinigung
**Fund:** Der Review (R-8, INFO) und der Verifier fanden die Klasse im **Bestand** von `test/mutate-driver.bats`, einer Datei,
die der Slice um elf Tests erweitert hat. Gemessen 2026-09-26, keine Erwartungswerte: `grep -c '^  ! grep' test/mutate-driver.bats`
→ 19; davon nicht als letzte Anweisung ihres Tests
`awk '/^  ! grep/{getline n; if (n != "}") c++} END{print c+0}' test/mutate-driver.bats` → 12 (der Review zählte mit einem
anderen Muster 13). Die Probe im gepinnten bats-Bild bestätigte die Falle: `! grep` mitten im Test schlägt nicht an, als
letzte Zeile schon. Die neuen Tests des Slice meiden die Form
(`git diff 09159a4a..HEAD -- test/mutate-driver.bats | grep -c '^+  ! grep'` → 0). **Urteil des Planners:** dieselbe
Beobachtung (eine Negation, die nicht das letzte Kommando ihres Falls ist); der Fund liegt im Bestand, nicht im Code des
Slice, und ob jede der zwölf Stellen wirkungslos ist, ist nicht je Stelle mutiert. Der Bestand ist kein Auftrag des Slice und
wurde nicht geändert.
