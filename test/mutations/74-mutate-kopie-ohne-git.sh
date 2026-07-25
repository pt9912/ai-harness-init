#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: die Kopie traegt den Sensor-Bedarf inklusive .git
#
# Spart .git wieder aus der isolierten Kopie aus — der erste Entwurf dieses Slice, der
# real brach: `make ci-lint` faehrt actionlint, und das verlangt eine git-Projektwurzel
# ("no project was found in any parent directories"). Der Gruen-Vorlauf fing es damals;
# ein Fall haelt die Eigenschaft jetzt dauerhaft (Review F-3: fuenf neue Waechter, aber
# nur zwei Faelle — ausgerechnet der schon einmal gebrochene war unbewacht).
set -euo pipefail
sed -i 's|tar -cf - --exclude=./.harness/state|tar -cf - --exclude=./.git --exclude=./.harness/state|' harness/tools/mutate.sh
