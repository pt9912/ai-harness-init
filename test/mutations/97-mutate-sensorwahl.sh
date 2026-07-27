#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: narrow_sensor faellt bei LEERER Erwartung auf den vollen Satz zurueck
#
# Entschaerft die Fail-closed-Regel der Sensor-Wahl: eine LEERE Erwartung liefert danach
# die bats-Stufe statt des vollen Satzes. Ein Fall mit unklarer Erwartung wuerde dann nur
# noch die Haelfte pruefen — der Lauf waere schneller und saehe weniger, also genau das
# stille Gruen, gegen das make mutate antritt (LH-QA-01). Bis slice-056 gab es die Wahl
# nicht; mit ihr braucht sie einen Waechter.
set -euo pipefail
sed -i "s/printf '%s' 'test'; return ;;/printf '%s' 'test-bats'; return ;;/" harness/tools/mutate.sh
