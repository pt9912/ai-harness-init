**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Das Feld `program` nennt seit diesem Slice bei einer Zeile mit Zuweisung das Programm nach
den Zuweisungs-Segmenten oder nichts; Spans davor tragen an derselben Stelle einen Operator oder ein
Wert-Bruchstück. Der Plan schließt den Nachzug des Bestands aus (append-only, kein Leser wertet den
Wert als Programm aus), und kein Feld trägt die Fassung.
