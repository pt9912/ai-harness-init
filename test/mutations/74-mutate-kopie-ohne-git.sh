#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: die Kopie traegt den Sensor-Bedarf inklusive .git
#
# Spart .git wieder aus der isolierten Kopie aus — der erste Entwurf dieses Slice, der
# real brach: `make ci-lint` faehrt actionlint, und das verlangt eine git-Projektwurzel
# ("no project was found in any parent directories"). Der Gruen-Vorlauf fing es damals;
# ein Fall haelt die Eigenschaft jetzt dauerhaft (Review F-3: fuenf neue Waechter, aber
# nur zwei Faelle — ausgerechnet der schon einmal gebrochene war unbewacht).
#
# prepare_isolation traegt den Ausschluss ueber die benannte ISOLATION_EXCLUDES-Liste,
# nicht ueber ein Inline-`--exclude=` im tar-Aufruf; der Patch zielt auf diese Definition.
set -euo pipefail
sed -i 's|^ISOLATION_EXCLUDES=(\./\.harness/state)|ISOLATION_EXCLUDES=(./.git ./.harness/state)|' harness/tools/mutate.sh
