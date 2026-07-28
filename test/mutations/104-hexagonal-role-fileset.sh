#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_GoHexagonalProfile_FileSet
#
# Nimmt eine Kern-Datei aus dem hexagonalen Rollen-Renderer (die greeting.go-Map-Zeile).
# Das emittierte Skelett ist dann unvollstaendig: greet.go ruft NewGreeting, der Typ fehlt,
# das Ziel-Modul uebersetzt NICHT mehr — TestGenerate_GoHexagonal_Compiles faellt also mit.
# Der Datei-Satz-Waechter ist trotzdem der, der die EIGENSCHAFT haelt („das Layout traegt
# genau diese Dateien"): er benennt die fehlende Datei, waehrend der Compile-Beleg nur sagt,
# dass irgendetwas nicht uebersetzt. Genau darum steht er in der `# expect:`-Zeile.
# (Die erste Fassung dieses Kommentars behauptete das Gegenteil — „uebersetzt weiter",
# „der einzige Waechter" —; die Verifikation zu slice-058 hat es widerlegt, Befund A-2.
# Eine falsche Begruendung im Sensor-Korpus ist dieselbe Klasse wie Review-F-4.)
# Das Match auf die Zeile MIT Komma trifft nur den Map-Eintrag (Muster wie Fall 61).
set -euo pipefail
sed -i '/"internal\/hexagon\/core\/greeting.go": goHexagonalGreeting,/d' internal/gen/golang.go
