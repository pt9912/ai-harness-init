#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestCarrierPath_NimmtDieEndungMit
#
# NIMMT DEM ZIEL-NAMEN DIE ENDUNG DES LAUFENDEN BILDES.
#
# Auf einem Windows-Host laege der Traeger danach ohne `.exe` im Zustands-Bereich — eine
# Datei, die das System nicht startet. Der Ausfall waere still: der Wrapper faende
# nichts Ausfuehrbares, schwiege (das ist seine erlaubte Betriebsart) und das Ziel
# erfasste dauerhaft nichts. Auf einem Linux-Lauf ist die Wirkung unsichtbar, deshalb
# misst der Waechter die Ableitung selbst statt ihr Ergebnis auf DIESER Plattform
# (LH-QA-04).
set -euo pipefail
sed -i 's@^\t\treturn carrierDir + "/" + carrierName + ext$@\t\treturn carrierDir + "/" + carrierName@' internal/emit/enforce.go
