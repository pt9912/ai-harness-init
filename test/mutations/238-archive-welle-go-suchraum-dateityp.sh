#!/usr/bin/env bash
# files: internal/archive/scan.go
# expect: TestHaengerFindetVerweisAusNichtMarkdownDatei
# verify: test-go
#
# Zieht eine zweite Achse in den Suchraum ein, in dem das Unterkommando nach
# lebenden Verweisen sucht: nur noch `.md`.
#
# Der Suchraum ist der GIT-INDEX, ohne Endungs-Filter: im Bestand tragen
# Shell-Hooks und -Helfer, Go-Kommentare, Mutations-Faelle und bats-Dateien
# Verweise auf Review-Reports. Mit der Verengung meldet die Vorpruefung
# "Sperren: keine" — und weil der schreibende Zweig genau diese Vorpruefung
# fahrt, laeuft er durch, loescht den Report und laesst einen lebenden Verweis
# ins Leere zeigen. Das Rot kommt dann von `make docs-check`, nach zwei Commits,
# und in einer nach AGENTS.md 3.4 eingefrorenen Datei ist es nicht behebbar.
#
# Die Verengung faellt nicht von selbst auf. Sie steht an einer anderen Stelle
# als die Ausnahme-Menge, gegen die der bestehende Suchraum-Fall
# (233-archive-welle-go-haenger-suchraum.sh) faehrt, und jeder Test mit einer
# `.md`-Datei als Verweiser bleibt gruen.
set -euo pipefail
sed -i 's@^\t\tif rel == "" || gesehen\[rel\] || Ausgenommen(rel) {$@\t\tif rel == "" || gesehen[rel] || Ausgenommen(rel) || !strings.HasSuffix(rel, ".md") {@' internal/archive/scan.go
