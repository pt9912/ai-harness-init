#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_Convergent
#
# Enforce wird von KONVERGENT auf skip-if-present umgebogen (writeFileMode -> writeSkipIfPresent):
# dann heilt ein Re-Lauf eine adopter-modifizierte Mechanik-Datei NICHT mehr (slice-038 Drift).
# Der Konvergenz-Waechter (kanonisch neu schreiben) muss rot werden.
set -euo pipefail
sed -i 's/writeFileMode(targetDir, f.dst/writeSkipIfPresent(targetDir, f.dst/' internal/emit/enforce.go
