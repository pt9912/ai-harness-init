**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Die Wortgrenze der Nacharbeit gilt über `splitWords` für **jede** Zeile, nicht nur für
Zeilen mit Zuweisung. Vorher/nachher an der Stichprobe des Reviewers (Runde 2, LOW): `make\r` →
`"make"` wird `"make\r"`; `ls<NBSP>-l` → `"ls"` (argc 1) wird `"ls<NBSP>-l"` (argc 0). Der Verifier
maß dasselbe am gebauten Träger. Die DoD spricht nur von Zeilen mit Zuweisung; Zeilen ohne
Zuweisung haben keinen eigenen Fall, Fall 406 mutiert `splitWords` mit.
