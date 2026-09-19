**Vorgang:** slice-release-schnitt-koppelt-pin-und-fassung

**Fund:** Drei Fundstellen der Klasse, alle in diesem Vorgang. (1) Der
`v0.2.0`-Tag: sein Baum trug die beschädigte Makefile-Fassung — ge-tagt,
ohne Gates-Beleg (benannt im Beleg-Kontext des Bootstrap-Unfalls:
`../../ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md`,
Abschnitt Schaden). (2) Die zwei Pushes nach dem ersten rot — gepushte
Zwischenstände ohne eigenen geprüften Stand an der Spitze (dieselbe Datei,
Abschnitt CI-Lage). (3) Der `v0.2.1`-Tag (`28337be5`): geschnitten und
veröffentlicht auf der ungeprüften Zwischenstufe — vor dem Accept von
`ADR-0059` (`ca0b5254`) und vor der Closure; der Gates-Beleg des Baums lag
lokal (`.harness/state/gates-passed.diffsha`, gitignored) und reist nicht
mit dem Tag, die CI-Meldung traf nach der Veröffentlichung ein.

**Klasse:** Ein ge-tagter/gepushter Stand trägt keinen Gates-Beleg. Die
Disziplin (Gates am Tag-Baum vor dem Tag-Push · CI am Tag abwarten, bevor
der Schnitt vollzogen gemeldet wird) steht in keinem Artefakt;
`slice-releasing-doku-traegt-den-release-vorgang` (in `open/`) schreibt sie
als Prozedur.

**Form:** Ein Beleg, nicht drei — alle drei Fundstellen liegen im selben
Vorgang, und die Zählregel misst Wiederholung über Vorgänge hinweg, nicht
die Zahl der Funde. Die Kennung ist nötig, weil die Klasse bisher unter
fremden Beobachtungen mitlief (Fundstellen 1 und 2 im Beleg-Kontext des
Unfalls) und ohne eigene Kennung nie die Schwelle erreichen könnte.