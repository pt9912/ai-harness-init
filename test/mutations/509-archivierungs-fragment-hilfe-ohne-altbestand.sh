#!/usr/bin/env bash
# files: internal/emit/templates/enforce/archivierung.mk
# expect: TestArchivierungFragment_HilfeNenntDenAltbestandSchluessel
# verify: test-go
#
# Die `##`-Hilfezeile verliert den Schluessel altbestand; der Kopfkommentar
# nennt ihn weiter.
set -euo pipefail
sed -i '/^archive-welle:/s/ | WELLE=altbestand//' internal/emit/templates/enforce/archivierung.mk
