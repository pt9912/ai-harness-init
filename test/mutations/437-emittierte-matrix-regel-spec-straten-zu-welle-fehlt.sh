#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/regel_spec_straten_welle
#
# Entfernt die matrix-Regel {from: spec-straten, to: welle, allow: false}: die Klasse welle
# steht vor aussen, also faengt aussen eine Welle-Datei nicht, und ein Spec-Stratum darf
# eine Welle danach nennen.
set -euo pipefail
sed -i '/{from: spec-straten, to: welle, allow: false}/d' internal/emit/templates/d-check.yml
