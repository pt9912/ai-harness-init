#!/usr/bin/env bash
# files: internal/archive/scan.go
# expect: TestHaengerFindetVerweisAusNichtMarkdownDatei
# verify: test-go
#
# Zieht eine zweite Achse in den Suchraum ein, in dem das Unterkommando nach
# lebenden Verweisen sucht: nur noch `.md`.
#
# Der schreibende Traeger sucht denselben Verweis mit `git grep` in JEDER
# getrackten Datei ausser der Baseline — die Pathspec kennt keine Endung. Im
# Bestand tragen Shell-Hooks und -Helfer, Go-Kommentare, Mutations-Faelle und
# bats-Dateien Verweise auf Review-Reports. Mit der Verengung meldete die
# Vorschau "Sperren: keine — der schreibende Lauf liefe" und gaebe Exit 0 aus,
# waehrend der Traeger mit Exit 3 abbraeche. Das ist die teuerste Fehlerrichtung
# dieses Zweigs: er sagt zu, vorherzusagen, was die Archivierung taete.
#
# Die Verengung faellt nicht von selbst auf. Sie steht an einer anderen Stelle
# als die Ausnahme-Menge, gegen die der bestehende Suchraum-Fall
# (233-archive-welle-go-haenger-suchraum.sh) faehrt, und jeder Test mit einer
# `.md`-Datei als Verweiser bleibt gruen.
set -euo pipefail
sed -i 's@^\t\tif rel == "" || gesehen\[rel\] || Ausgenommen(rel) {$@\t\tif rel == "" || gesehen[rel] || Ausgenommen(rel) || !strings.HasSuffix(rel, ".md") {@' internal/archive/scan.go
