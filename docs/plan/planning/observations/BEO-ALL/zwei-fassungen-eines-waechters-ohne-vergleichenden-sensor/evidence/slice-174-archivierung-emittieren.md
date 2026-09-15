**Vorgang:** slice-174-archivierung-emittieren
**Fund:** Der Wellen-Closure-Ablauf liegt zweimal im Repo, und dieser Vorgang hat die **emittierte**
Fassung berührt: `.claude/commands/close-welle.md` (ausgeführt) und
`internal/emit/templates/commands/close-welle.md` (Vorlage). Ihre Schritt 2 fallen auseinander —
die ausgeführte prüft **eine** Trigger-Klasse (Carveout-Audit), die Vorlage **drei** (Carveout,
Reifestufen, Entscheidung) —, und kein Sensor hält die zwei Fassungen gegeneinander: die
Go-Textanker prüfen die **Form** (Vorhandensein eines `ANPASSEN`-Markers,
`TestCommands_AdaptationMarker`), nicht die Gleichheit, und `make test` fährt jede Fassung nur für
sich. Eine einseitige Änderung an einer der zwei ließe beide Suiten grün und die Zusage ihrer
Gleichheit still falsch werden. Das zweite Paar desselben Vorgangs — das Dogfood-Ziel
`archive-welle` im `Makefile` gegen das emittierte `archivierung.mk` — ist dagegen die
**Nachbarklasse**: diese zwei **sollen** auseinandergehen (das Ziel-Binär wird abgelegt, nicht
gebaut), während der Ablauf gleich bleiben soll.
