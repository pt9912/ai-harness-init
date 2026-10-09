#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleAltbestandOhneKennungEndetAlsAufrufFehler
# verify: test-go
#
# DIE KENNUNGS-PFLICHT GREIFT AUCH UNTER --vorschau: der Blick auf den Altbestand
# verlangt eine Kennung, obwohl er nichts schreibt und keinen Commit-Text braucht
# (ADR-0090 Festlegung 3 b). Der Fall meldet "Vorschau ohne Kennung: Exit 2, want 0".
set -euo pipefail
sed -i 's/^\tif vorschau {$/\tif vorschau \&\& welle == archive.AltbestandSchluessel \&\& kennung == "" {\n\t\treturn 2\n\t}\n&/' cmd/ai-harness-init/archive_welle.go
grep -q '^	if vorschau && welle == archive.AltbestandSchluessel && kennung == "" {$' cmd/ai-harness-init/archive_welle.go
