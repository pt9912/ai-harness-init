#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: fastpfad: fehlender Key (leer) -> voller Lauf (fail-closed)
# verify: test-bats
#
# MACHT AUS DEM Deckungs-VERGLEICH EINEN BLANKOSCHECK: die gedeckt-Zeile der
# Klassifikation (`deck_oder_drift`, `if [ "$1" = "$2" ]; then return 0; fi`) wird
# zu `if true; then return 0; fi` — der je-Check-Key SKIPpt dann, ohne dass sein
# Stempel den Prüfgegenstand deckt (fehlt, fremder Wert oder geleert gilt), also
# ohne gedeckten Satz. Genau der Luecken-Skip, den ADR-0108 Festlegung 1 verweigert:
# der SKIP behauptete ein Verdikt, das kein Lauf ueber diesem Baum getragen hat.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: Aufrufer ist das Make-Target `gates` ueber
# `bash harness/tools/gates-fast.sh`; die bats-Stufe faehrt dieselbe Klassifikation
# ueber `--entscheide`, denselben Einstieg, den der volle Lauf am Ende aufruft.
#
# ANKER: die gedeckt-Zeile traegt in gates-fast.sh genau einmal die Marke
# `# gedeckt` am Zeilenende; die Adresse `# gedeckt$` greift nur sie. Ohne die
# Marke waere `s@..1. = ..2.@` mehrdeutig gegen die Ist-Bestsand-Zeilen des Skripts.
#
# ERWARTETER ROT-GRUND: `fastpfad: fehlender Key (leer) -> voller Lauf (fail-closed)`
# wird rot, weil ein fehlender Stempel SKIP ergibt (Exit 0 statt 1); die
# unformalen Zustaende fallen weiter in Exit 1 und faerben nicht mit. Schwester-Fall
# 793 haelt die Gegenrichtung (alles driftet statt alles gedeckt).
set -euo pipefail
sed -i '/# gedeckt$/s@\[ ..1. = ..2. \]@[ true ]@' harness/tools/gates-fast.sh
