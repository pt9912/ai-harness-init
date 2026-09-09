**Vorgang:** slice-129
**Fund:** Die neue `test/closure-modul-wiring.bats` trat mit sechs Zusicherungen an, und die erste
Runde lieferte drei Fälle unter `test/mutations/`; drei Zusicherungen — darunter die, die den
Grund-Code der Meldung und die Nicht-Rekursion des Prüfbereichs halten — standen ohne gelisteten
Fall und waren nach der Feststellung des Repos *„wer keinen Fall in `test/mutations/` hat, ist
unbewacht"* ([`AGENTS.md`](../../../../../../../AGENTS.md) §3.6) ungedeckt. In der zweiten Runde
vollständig behoben (Fälle 285–290, je genau eine Zusicherung treffend); der Beleg zählt das
Auftreten in der Lieferung, nicht den Rest nach der Behebung.
