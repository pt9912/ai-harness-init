#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/token_welle
#
# Setzt das token: der Klasse welle auf die Ziffern-Form zurueck: ein benannter Welle-Name
# ist dann in einer ADR und einer Spec-Datei kein Fund mehr, nur welle-07 waere einer.
set -euo pipefail
sed -i "s/token: 'welle-'}/token: 'welle-\\\\d{2}'}/" internal/emit/templates/d-check.yml
