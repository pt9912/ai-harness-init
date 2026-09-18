**Vorgang:** slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung
**Fund:** Drei Stellen, eine Klasse. **(a)** Der Slice dreht die Spaltenfolge der
Abdeckungs-Sicht und nimmt der ausgelieferten Fassung den Verweis-Zweig; `LH-FA-12`
§Benannte Grenze beschreibt den Code-Span weiter als **Ausnahme** für die nicht auflösende
Kennung (*„Löst eine genannte Kennung in der Spec des Ziels nicht auf, steht sie als
Code-Span ohne Verweis statt als Befund"*), während die emittierte Fassung ihn als **Regel**
für jede Kennung schreibt und nie einen Anker ableitet — wörtlich wahr, die Implikatur des
Konditionals überholt (Review Runde 4, Verifikation V-3). **(b)** Mit dem Verweis-Zweig fiel
der Hinweis auf eine fehlende Spec-Datei weg, während die geschriebene Sicht sie weiter als
Maßstab des Lesers nennt (Review Runde 4; im Slice mit `ac814e63` behoben, der den Hinweis
an beiden zugesagten Stellen wiederherstellt). **(c)** §3 des Slice-Plans nennt vier
berührte Dateien nicht — `Makefile`, `internal/emit/makefile.go`,
`internal/emit/baumaussage_test.go`, `test/full-smoke-ausgang.bats`; alle vier sind
notwendige Folgen und verletzen §1 nicht, die Plan-Zeile daneben blieb unverändert stehen
(Review Runden 1–3, Verifikation V-2).
**Kein Gate sieht eine der drei.** Ein Doku-Sensor prüft Verweise und Anker, nicht, ob ein
Satz neben einer bewegten Ableitung noch trägt; `make docs-check` blieb über alle vier
Runden grün. Träger war jedes Mal das Review, einmal die Verifikation.
