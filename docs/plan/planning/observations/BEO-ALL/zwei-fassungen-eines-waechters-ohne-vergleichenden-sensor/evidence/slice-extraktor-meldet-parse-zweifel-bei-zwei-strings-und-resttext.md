**Vorgang:** slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext
**Fund:** Der Extraktor des Tool-Call-Wächters liegt zweimal im Repo (`harness/tools/extract-command.awk`,
`internal/emit/templates/enforce/extract-command.awk`); die Fassungen sind nicht byte-gleich, sie weichen
in Kommentarzeilen ab. Die Änderung musste beide Fassungen tragen, und die Gleichheit der Code-Zeilen
hielt allein eine einmalige Handmessung des Verifiers
(`diff <(grep -v '^[[:space:]]*#' …) <(grep -v '^[[:space:]]*#' …)`, leer); kein Sensor hält sie beim
nächsten Eingriff. Die Probenschleife in `test/guard.bats` läuft über beide Pfade und die Fälle 780 bis 783
brechen je Fassung, vergleichen die Fassungen aber nicht gegeneinander.
