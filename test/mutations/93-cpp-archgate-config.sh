#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestArchGateConfig_CppMatchesSkeleton
#
# Nimmt die cpp-Arch-Gate-Config aus archGateConfigs: die Kombination cpp+hexslice rendert
# dann Schichten OHNE Config — ArchGateConfig meldet ok=false, der Aufrufer emittiert kein
# .a-check.yml, und das geschichtete C++-Modul liefe ohne Architektur-Gate (still gruen,
# LH-QA-01). Genau diese Kopplung Achse<->Config erzwang die Grenzverschiebung zwischen
# slice-053 und slice-054. Match `"cpp": {archHexslice` ist eindeutig und SC2016-clean.
set -euo pipefail
sed -i '/"cpp":  *{archHexslice/d' internal/gen/arch.go
