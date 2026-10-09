#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleAltbestandSperreGehtDerKennungsPflichtVor
# verify: test-go
#
# DIE KENNUNGS-PFLICHT UEBERHOLT DIE SPERREN: ein Altbestand-Lauf ohne Kennung endet
# mit Exit 2 und der Kennungs-Meldung, auch wo eine Sperre der Vorpruefung steht —
# der Bediener nennt die Kennung und laeuft danach erst in die Sperre (ADR-0090
# Festlegung 3 a). Der Fall meldet "Exit 2, want 3 (die Sperre)".
set -euo pipefail
sed -i 's/^\tif len(bericht\.Sperren) > 0 {$/\tif welle == archive.AltbestandSchluessel \&\& kennung == "" \&\& !vorschau {\n\t\tfmt.Fprintln(errOut, "archive-welle: --kennung fehlt")\n\t\treturn 2\n\t}\n&/' cmd/ai-harness-init/archive_welle.go
grep -q '^		fmt.Fprintln(errOut, "archive-welle: --kennung fehlt")$' cmd/ai-harness-init/archive_welle.go
