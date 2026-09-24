**Vorgang:** slice-program-feld-nennt-weder-operator-noch-wertfragment
**Fund:** Der Beleg des Implementers (`396 ok, 0 Befund(e)`) war nach dem Review-Report der Runde 2
nicht mehr am Endstand gültig (Verifier V-1, MEDIUM); der Versuch, den Übersprung mit
`timeout 120 make mutate` zu bestätigen, löschte den Beleg-Slot und endete mit Exit 130. Der
Endstand-Lauf lief am Stand `d7fc646672f4` mit `make mutate MUTATE_JOBS=8`: `mutate: 396 ok, 0
Befund(e)`, 1822 s; mit vier Arbeitern waren es 3039 s. Die Ausgabe nennt die untere Schranke jeder
Parallelisierung — den längsten Einzelfall, 167.12 s — und die Fall-Arbeit gesamt, 13234.0 s.
