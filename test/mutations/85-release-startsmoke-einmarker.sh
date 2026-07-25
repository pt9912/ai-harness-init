#!/usr/bin/env bash
# files: harness/tools/start-smoke.sh
# expect: start-smoke FAELLT bei nur EINEM Marker
#
# Reduziert die Marker-Menge auf einen. Eine Usage, die nur den Werkzeugnamen nennt,
# ginge dann als Nachweis durch — die zweite Haelfte der Zusage ("beide Marker") waere
# unbelegt. Runde 3 (F-4) hat gemessen, dass die Ein-Marker-Variante unter den damaligen
# Fixtures gruen blieb.
set -euo pipefail
sed -i "s|for marker in 'ai-harness-init' 'add-lang'|for marker in 'ai-harness-init'|" harness/tools/start-smoke.sh
