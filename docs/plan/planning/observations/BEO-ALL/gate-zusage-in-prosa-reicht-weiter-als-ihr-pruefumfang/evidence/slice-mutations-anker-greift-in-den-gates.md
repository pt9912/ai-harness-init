**Vorgang:** slice-mutations-anker-greift-in-den-gates

**Fund:** Die Zeile `make mutate-greift` in `harness/README.md` §Sensors sagt „jeder Mutations-Fall"; `MUTATE_CASES` aus der Umgebung engt den Lauf ein, und `record-gates` stempelte den eingeengten Lauf (Review I-1). Behoben mit `unset MUTATE_CASES` im Rezept.
