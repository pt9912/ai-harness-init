#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestAdaptArchMK_PinsProducingRef
#
# Nimmt das Um-Pinnen des Arch-Gate-Fragments zurueck: die A_CHECK_IMAGE-Zeile bleibt so,
# wie a-check sie DRUCKT. Real hinkt dieser gebackene Pin dem laufenden Image nach
# (v0.15.0 gemessen), das emittierte Fragment behauptete also eine Herkunft, die nicht
# stimmt (LH-QA-02). Der Wert `s[i:]` haelt beide Variablen (s, i) in Benutzung — die
# Mutation faerbt an der Assertion rot, nicht am Compiler.
set -euo pipefail
sed -i 's|body = anchor + " " + ref + body\[nl:\]|body = s[i:]|' internal/emit/archgate.go
