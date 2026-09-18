#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Entfernt die Klasse aussen aus der emittierten .d-check.yml: ohne sie hat die Regel
# spec-straten -> aussen keine Quelle mehr, und ein Spec-Stratum des Ziels darf wieder
# auf jede Datei zeigen, die keine andere Klasse fuehrt.
set -euo pipefail
sed -i '/^    - {name: aussen, paths: \["\*\*"\]}$/d' internal/emit/templates/d-check.yml
