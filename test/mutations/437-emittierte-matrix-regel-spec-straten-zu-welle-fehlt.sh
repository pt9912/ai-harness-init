#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/regel_spec_straten_wave
#
# Entfernt die matrix-Regel {from: spec-straten, to: wave, allow: false}: die Klasse wave
# steht vor aussen, also faengt aussen eine Wave-Datei nicht, und ein Spec-Stratum darf
# eine Wave danach nennen.
set -euo pipefail
sed -i '/{from: spec-straten, to: wave, allow: false}/d' internal/emit/templates/d-check.yml
