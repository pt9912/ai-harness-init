#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerateCsharp_TagOhneMajorMinorBrichtAb
#
# Die Versions-Pruefung in GenerateArch wird ausgeschaltet -> ein Tag ohne Major.Minor (latest, 10)
# bricht den Generator nicht mehr ab, das Skelett entstuende mit einer ungueltigen TFM
# (ADR-0096 Festlegung 2).
set -euo pipefail
sed -i 's/if check, ok := versionValidators()\[lang\]; ok {/if check, ok := versionValidators()[lang]; ok \&\& false {/' internal/gen/gen.go
