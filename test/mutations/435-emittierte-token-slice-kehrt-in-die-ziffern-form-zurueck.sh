#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/token_slice
#
# Setzt das token: der Klasse slice auf die Ziffern-Form zurueck: ein benannter Slice
# ist dann in einer ADR und einer Spec-Datei kein Fund mehr, nur slice-042 waere einer.
set -euo pipefail
sed -i "s/token: 'slice-'}/token: 'slice-\\\\d{3}'}/" internal/emit/templates/d-check.yml
