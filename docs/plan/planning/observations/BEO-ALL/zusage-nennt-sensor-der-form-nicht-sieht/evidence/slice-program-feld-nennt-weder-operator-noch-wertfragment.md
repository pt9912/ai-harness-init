**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Der Funktionskommentar über `commandProgram()` sagt zu, eine Zeile mit Zuweisung nenne ein
Programm oder nichts; der Code hält es für Operatoren und Wert-Bruchstücke (Runde 1, MEDIUM, in der
Nacharbeit geschlossen), nicht für Wörter mit `$(`, `"` oder Backtick in Programm-Position
(`A=b $(echo SECRET) cmd` → `$(echo`, Runde 2, INFO). Die Zusage nennt keinen Sensor, der den Rest
auffinge; der Geltungsbereich des Satzes ist weiter als der des Codes darunter.
