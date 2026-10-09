#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestArchGateConfig_KotlinMatchesSkeleton
# verify: test-go
#
# Die Sprache kotlin verliert ihren Eintrag in der Arch-Gate-Tabelle: der One-Shot
# --lang kotlin --arch hexslice legt am Root das Schicht-Skelett ohne .a-check.yml und ohne
# Arch-Gate-Fragment ab, das Ziel faehrt kein Arch-Gate (LH-FA-07, ADR-0088 Festlegung 4).
# Die Mutation faerbt fuenf Tests rot: TestArchGateConfig_OnlyLayered,
# TestArchGateConfig_CoversEveryLayeredCombo, TestArchGateConfig_KotlinMatchesSkeleton,
# TestArchGateConfig_KotlinEdgesMatchSkeleton und TestRun_BootstrapKotlinRoot; keiner davon
# bindet die Zeile allein. Der Fall nennt den kotlin-eigenen Test, das Gegenstueck zu
# test/mutations/93 fuer cpp.
set -euo pipefail
sed -i '/^\t\t"kotlin": {archHexslice: kotlinHexArchConfig},$/d' internal/gen/arch.go
