**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** `SPEC-031` nannte in Runde 1 vier Gruppen nicht bestimmbarer Wert-Ränder, der Code
dreizehn Zeichen (Review, INFO; in der Nacharbeit auf die Code-Menge gebracht). Übrig ist die Lücke des Verifiers
(V-3, LOW): die Zeile nennt `;` unter den Zeichen mit unbestimmbarem Rand und schweigt zu einem
einzelnen `;` am Wertende — `A=b; cmd x` liefert im Code, in der Plan-Tabelle und im Test `cmd`.
