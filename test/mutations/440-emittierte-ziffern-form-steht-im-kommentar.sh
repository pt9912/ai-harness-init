#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/keine_ziffern_form
#
# Traegt die Ziffern-Form einer Slice-Kennung in den Herkunfts-Kommentar ein: die Vorlage
# nennt sie dann wieder, und ein Leser liest sie als Form, die das Ziel traegt.
set -euo pipefail
sed -i 's|^# Herkunft der Positionen in diesem Block, gemessen gegen die Baseline-Vorlage$|& slice-\\d{3}|' internal/emit/templates/d-check.yml
