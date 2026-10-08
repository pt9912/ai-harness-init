#!/usr/bin/env bash
# files: spec/spezifikation.md
# expect: TestFeldliste_BestandNurAusdruecklichGeraeumt
#
# DIE SPEZIFIKATION NUMMERIERT DEN ABSCHNITT DER TRACING-FELDER UM, die Feldliste nennt ihn
# als Quelle unveraendert unter „§5" weiter. Die Mutation sitzt an der realen Quelle, der
# Ueberschrift in der Spezifikation: die Abschnittsnummer der Quellen-Angabe ist an sie
# gekoppelt, nicht an eine Abschrift im Test. Die drei uebrigen Saetze der Feldliste fallen
# mit (ihre Tests lesen dieselbe Ueberschrift); gebunden ist hier der Aufbewahrungs-Satz.
set -euo pipefail
sed -i 's@^## 5\. Metriken und Tracing-Felder$@## 9. Metriken und Tracing-Felder@' spec/spezifikation.md
