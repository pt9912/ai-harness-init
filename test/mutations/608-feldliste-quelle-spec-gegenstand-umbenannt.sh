#!/usr/bin/env bash
# files: spec/spezifikation.md
# expect: TestFeldliste_BestandNurAusdruecklichGeraeumt
#
# DIE SPEZIFIKATION BENENNT DEN GEGENSTAND DER ZEILE SPEC-057 UM, die Feldliste nennt ihn
# als Quelle unveraendert weiter. Die Mutation sitzt an der realen Quelle, nicht an der
# Feldliste: die Quellen-Angabe ist an die Zelle der Spezifikation gekoppelt, nicht an eine
# Abschrift im Test.
set -euo pipefail
sed -i 's@ | Altbestände (Abweichung 4) | @ | Bestand (Abweichung 4) | @' spec/spezifikation.md
