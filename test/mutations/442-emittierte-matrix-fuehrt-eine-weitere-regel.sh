#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/regel_menge
#
# Haengt der Regel-Liste eine Regel an, die die Liste der Vorlage nicht nennt: die Menge
# der Regeln ist geschlossen, jede weitere ist eine Entscheidung.
set -euo pipefail
sed -i 's|^    - {from: adr, to: welle, allow: false}$|&\n    - {from: adr, to: aussen, allow: false}|' internal/emit/templates/d-check.yml
