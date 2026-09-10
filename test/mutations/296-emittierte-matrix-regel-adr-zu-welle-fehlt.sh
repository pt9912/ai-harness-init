#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Entfernt die matrix-Regel {from: adr, to: welle, allow: false} aus der emittierten
# .d-check.yml: der Waechter bindet beide neuen adr->{slice,welle}-Regeln, nicht nur die
# erste — ohne die Zeile faerbt er rot.
set -euo pipefail
sed -i '/{from: adr, to: welle, allow: false}/d' internal/emit/templates/d-check.yml
