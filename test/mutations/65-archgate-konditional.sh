#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestRun_AddLangArchFlatEmitsNoArchGate
#
# Kappt die KONDITIONALITAET des Arch-Gates: der Frueh-Return fuer nicht-schichten-
# tragende bzw. sprach-fremde Kombinationen liefert statt "kein Gate" die hexSlice-Config.
# Damit bekaeme auch ein FLACHES Modul ein .a-check.yml + a-check.mk + Gate-Fragment —
# ein Architektur-Gate ueber leerem Pruefbereich, genau der halluzinierte Gate aus
# LH-QA-01. Die Mutation bricht VERHALTEN, nicht das Kompilat (cfg/ok bleiben unten
# benutzt); `return "", false` kommt in arch.go genau einmal vor. SC2016-clean.
set -euo pipefail
sed -i 's/return "", false/return goHexArchConfig, true/' internal/gen/arch.go
