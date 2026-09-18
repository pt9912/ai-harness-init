#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Nimmt das token: von der Klasse adaptionsblock: die blosse MR-Kennung im Fliesstext
# eines Spec-Stratums ist dann keine Referenz mehr, und im Ziel faengt sie niemand —
# ein ids-Muster gibt es dafuer dort nicht.
set -euo pipefail
sed -i "s/, token: 'MR-\\\\d{3}'}/}/" internal/emit/templates/d-check.yml
