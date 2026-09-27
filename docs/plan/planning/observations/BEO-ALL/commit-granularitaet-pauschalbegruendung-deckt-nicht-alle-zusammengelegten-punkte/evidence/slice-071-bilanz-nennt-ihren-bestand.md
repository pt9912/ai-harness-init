**Vorgang:** slice-071-bilanz-nennt-ihren-bestand
**Fund:** Review-LOW
(`docs/reviews/2026-09-27-review-slice-071-bilanz-nennt-ihren-bestand.md`, Klasse
`commit-granularitaet-pauschalbegruendung-deckt-nicht-alle-zusammengelegten-punkte`): Commit
`be0751b8` begründete die Zusammenlegung von DoD (1)/(2)/(3) mit „geteiltem switch-Block" — trifft
für (1)/(2) zu, nicht für (3), das in einem eigenen, unabhängig testbaren Codeblock mit eigenem
Test und eigenem Mutations-Fall (494) sitzt. Kein Hard-Rule-Verstoß (Modul 5 stellt
DoD-Granularität pro Commit ins Ermessen), LOW, kein Merge-Hindernis.
