#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_Convergent
#
# BlockedFragment wird von KONVERGENT (Review-I-1-Versoehnung, slice-038) zurueck auf skip-if-
# present umgebogen (writeFileMode -> writeSkipIfPresent): dann heilt ein Re-Lauf ein driftendes
# blocked/<sprache> NICHT mehr. Der Konvergenz-Waechter muss rot werden.
set -euo pipefail
sed -i 's/return writeFileMode(targetDir, BlockedFragmentPath/return writeSkipIfPresent(targetDir, BlockedFragmentPath/' internal/emit/enforce.go
