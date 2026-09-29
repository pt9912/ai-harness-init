**Vorgang:** slice-go-testlauf-bekommt-einen-ressourcendeckel
**Fund:** Review des Slices fand die Klasse dreimal an drei Stellen — F-2 (Makefile-Kommentar
über `test-go` nannte die entfernte `--no-cache-filter test`-Konfiguration neben der geltenden
Zusage), F-4 (`Makefile:163` verglich die Begründung von `--no-cache-filter build` mit derselben
seither entfernten Flag) und F-5 (eine Klammer-Passage im `test-go`-Kommentar trug das Protokoll
eines Diagnose-Laufs samt Mess-Zahl). Ein Vorgang — gezählt als ein Auftreten. Alle drei Funde
sind in `fb11116f` und `91acbd7a` behoben; die Grenze der Klasse steht am Zielort
(`AGENTS.md` §3.7, "Ein Wächter existiert nicht").
