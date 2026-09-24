**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Die Wert-Grenze von `commandProgram()` setzte die Wortgrenze der Go-Bibliothek mit der der
Shell gleich. Die Sonde des Reviewers fand über der unveränderten Funktion Unicode-Leerraum, `\r`,
`\v` im Wert (`A=b<NBSP>SECRET cmd` → `program="SECRET"`, Runde 1, HIGH) und Operator- und
Redirect-Wörter nach der Zuweisung (`|&`, `>f`, `<<<hunter2`, `#SECRET`, Runde 1, MEDIUM); beides
in der Nacharbeit geschlossen. In Runde 2 blieb ein Rest (INFO): Wörter mit `$(`, `"` oder Backtick
in Programm-Position (`A=b $(echo SECRET) cmd` → `$(echo`) sind weiter `program`. Die Tabelle des
Plans nannte keinen dieser Fälle.
