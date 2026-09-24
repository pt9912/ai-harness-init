**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Sechs Zeichen der Wert-Menge `unsureValueChars` hatten in Runde 1 (LOW) keinen eigenen
Zahn; die Nacharbeit schloss das mit dem Tabellentest
`TestCommandProgramWithholdsProgramForEachUnsureValueChar`. Für die zweite Menge, `shellMetaStart`,
blieb es in Runde 2 (LOW): entfällt `&` oder `)`, bleibt die volle Suite grün (vom Verifier
bestätigt); `<` und `>` sind äquivalente Mutanten, weil die Ziffernfolge-Regel dieselben Wörter
deckt.
