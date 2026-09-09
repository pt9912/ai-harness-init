**Vorgang:** slice-129
**Fund:** `planning.closure.dir` öffnet die Kandidaten **im genannten Verzeichnis selbst**, nicht
rekursiv — gemessen an einem Sonden-Paar außerhalb des Repos: dieselbe auf einen Satz gekürzte
`§7`-Datei einmal flach unter `done/` (**1** `closure-note-thin`), einmal unter einem synthetischen
`done/welle-99/` (**0** Treffer bei 1012 geprüften Dateien). Die Zusage im Doku-Absatz lautete
dagegen *„jeder `docs-check`-Lauf öffnet jetzt auch **jede** `slice-*.md` unter `done/`"*, und die
Grenze stand weder in der Gate-Config noch im Slice-Plan. Sie ist heute folgenlos, weil `done/` kein
Unterverzeichnis trägt — und wird mit dem ersten `archive-welle`-Lauf falsch, der Slice-Stubs nach
`done/<welle-id>/` bewegt; genau dieses Werkzeug entsteht im selben Checkout. Behoben durch eine
benannte Grenze im Doku-Absatz statt durch eine Weitung des Bereichs.
