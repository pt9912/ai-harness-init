#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Setzt exclude-sections der emittierten matrix-Klasse auf die fruehere, weitere
# Dogfood-Liste zurueck (den Wert vor 497e3980): der Waechter bindet exakt [Geschichte],
# nicht "irgendeine nicht-leere Liste" — der Rueckfall faerbt ihn rot.
set -euo pipefail
sed -i 's/^  exclude-sections: \[Geschichte\]$/  exclude-sections: [Historie, "7. Historie", Geschichte]/' internal/emit/templates/d-check.yml
