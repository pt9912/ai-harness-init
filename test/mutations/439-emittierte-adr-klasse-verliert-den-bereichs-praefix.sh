#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/adr_klasse_bereichs_praefix
#
# Nimmt der Klasse adr den Glob fuer Dateien mit Bereichs-Praefix: eine ADR-Datei
# IDX-0004-... liegt dann ausserhalb der Klasse, und ihre Slice-/Welle-Nennung faengt keine Regel.
set -euo pipefail
sed -i 's|, "docs/plan/adr/\[A-Z\]\*-\[0-9\]\*.md"||' internal/emit/templates/d-check.yml
