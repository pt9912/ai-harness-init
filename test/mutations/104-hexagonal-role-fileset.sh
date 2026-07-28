#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_GoHexagonalProfile_FileSet
#
# Nimmt eine Kern-Datei aus dem hexagonalen Rollen-Renderer (die greeting.go-Map-Zeile).
# Das Skelett entsteht dann unvollstaendig — und zwar STILL: es uebersetzt weiter (der
# Anwendungsfall in greet.go bliebe ohne seinen Domaenen-Typ nur so lange uebersetzbar,
# wie ihn niemand braucht), und keine Kanten- oder Rollen-Regel meldet sich. Der
# Datei-Satz-Waechter ist der einzige, der „das Layout ist vollstaendig" haelt.
# Das Match auf die Zeile MIT Komma trifft nur den Map-Eintrag (Muster wie Fall 61).
set -euo pipefail
sed -i '/"internal\/hexagon\/core\/greeting.go": goHexagonalGreeting,/d' internal/gen/golang.go
