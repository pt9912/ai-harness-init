**Vorgang:** slice-221
**Fund:** Die Lieferung legte an beiden Trägern frische Verdrahtung an, und an beiden nannte kein
Fall in `test/mutations/` sie. **Go** (Runde 1, HIGH-1): Die Trennung `Suchraum` gegen
`SuchraumNachzug` in `internal/archive/scan.go` war von keinem Test und keinem Fall gehalten —
`test/mutations/312` nennt `internal/archive/refs.go`, `test/mutations/233` die gemeinsame
Ausnahmeliste. Gemessen vom Reviewer:
`sed -i '168s/Suchraum(/SuchraumNachzug(/' internal/archive/scan.go && make test-go` → alle acht
Pakete `ok`. **Shell** (Runde 1 und 2, MEDIUM-1): `test/mutations/313` misst die Pathspec-Funktion,
nie ihren Gebrauch in `main()`; ersetzt man dort `"${in_pathspec[@]}"` wieder durch die harte
Pathspec, bleibt `make test-bats` grün. Geschlossen in der Nacharbeit durch `test/mutations/314`
(Go) und `315` (Shell), beide über je einem neuen Test.
