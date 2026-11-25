#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/token_wave
#
# Setzt das token: der Klasse wave auf die Ziffern-Form zurueck: ein benannter Wave-Name
# ist dann in einer ADR und einer Spec-Datei kein Fund mehr, nur wave-07 waere einer.
set -euo pipefail
sed -i "s/token: 'wave-'}/token: 'wave-\\\\d{2}'}/" internal/emit/templates/d-check.yml
