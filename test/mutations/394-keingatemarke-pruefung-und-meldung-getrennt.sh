#!/usr/bin/env bash
# files: internal/emit/erfassung_test.go
# expect: TestErfassung_ZeileMitDerMarkeBleibtOhneBefund
# verify: test-go
#
# TRENNT PRUEFUNG UND MELDUNG IN gateTabellenZeileBefund WIEDER IN ZWEI UNABHAENGIGE
# LITERALE — der Zustand vor 3147fe59: die PRUEFUNG verlangt "KEIN GATE" (Grossschreibung),
# die MELDUNG nennt weiterhin keinGateMarke ("kein Gate", klein). Eine Gate-Tabellen-Zeile,
# die GENAU die von der Meldung verlangte Schreibweise traegt, wird unter dieser Mutation
# trotzdem als Befund gemeldet — die Meldung sagt "akzeptiert wird kein Gate", die Pruefung
# akzeptiert aber nur KEIN GATE. Genau diese Divergenz haelt
# TestErfassung_ZeileMitDerMarkeBleibtOhneBefund fest (DoD (2) dieses Slice).
set -euo pipefail
sed -i 's/^\tif !strings.Contains(line, keinGateMarke) {$/\tif !strings.Contains(line, "KEIN GATE") {/' internal/emit/erfassung_test.go
