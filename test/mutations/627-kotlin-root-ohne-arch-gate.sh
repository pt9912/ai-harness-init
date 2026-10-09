#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestRun_BootstrapKotlinRoot
# verify: test-go
#
# Die Sprache kotlin verliert ihren Eintrag in der Arch-Gate-Tabelle: der One-Shot
# --lang kotlin --arch hexslice legt am Root das Schicht-Skelett ohne .a-check.yml und ohne
# Arch-Gate-Fragment ab, das Ziel faehrt kein Arch-Gate (LH-FA-07, ADR-0088 Festlegung 4).
set -euo pipefail
sed -i '/^\t\t"kotlin": {archHexslice: kotlinHexArchConfig},$/d' internal/gen/arch.go
