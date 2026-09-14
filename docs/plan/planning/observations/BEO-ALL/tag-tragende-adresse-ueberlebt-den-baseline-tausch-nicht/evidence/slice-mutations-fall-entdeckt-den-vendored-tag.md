**Vorgang:** slice-mutations-fall-entdeckt-den-vendored-tag
**Fund:** Fünf Fälle unter `test/mutations/` trugen `.harness/baseline/v6.7.2/templates/…` als
Literal in ihrer `# files:`-Zeile und im `sed`-Operanden. Der Sprung auf `v6.8.0` ersetzte den
Baum; `harness/tools/mutate.sh` bildet den Fingerabdruck über die Vereinigung aller
`# files:`-Ziele und brach danach fail-closed ab, **bevor der erste Fall lief** — `make mutate` war
auf jedem CI-Push rot, und die Meldung *„Fingerabdruck der Mutations-Ziele nicht berechenbar"*
nannte keine Datei. Der Nachzug war zuvor dreimal von Hand gefahren worden (slice-182: *„Symlinks
und die gekoppelten Mutations-Pfade ziehen"*, slice-193, slice-223) und beim vierten Sprung
ausgeblieben; im Plan von slice-223 kamen die Fälle schon nicht mehr vor. Die fünf Fall-Köpfe
hatten die Kopplung sogar **deklariert** — *„Nach einem Bump zeigt er ins Leere … Laut, nicht
still"* —, und benannten dabei eine Fehlschlag-Form (`merge_report`), die der Lauf gar nicht
erreicht: Laut war es, adressiert nicht.
