#!/usr/bin/env bash
# files: internal/emit/templates/enforce/archivierung.mk
# expect: TestArchivierungFragment_HilfeNenntDenAltbestandSchluessel
# verify: test-go
#
# Der Kopfkommentar verliert die Ablehnung `[kein-schreib-pfad]`.
set -euo pipefail
sed -i 's/\[kein-schreib-pfad\]/[abgewiesen]/' internal/emit/templates/enforce/archivierung.mk
