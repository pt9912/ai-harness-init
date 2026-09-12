#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: eingehend_ausgenommene_pfade: .harness/baseline und docs/plan/adr drin, docs/reviews NICHT (ADR-0042 Festlegung 2, ADR-0033 Abnahme-Kriterium 1)
# verify: test-bats
#
# ADR-0042 Festlegung 2: nimmt `':!docs/plan/adr'` wieder aus der
# EINGEHEND-Ausnahmeliste heraus — main() wuerde damit wieder in eine
# Accepted-ADR nachziehen, genau wie vor diesem Ausschluss.
set -euo pipefail
sed -i "s/printf '%s\\\\n' ':!\\.harness\\/baseline' ':!docs\\/plan\\/adr'/printf '%s\\\\n' ':!.harness\\/baseline'/" harness/tools/slice-mv.sh
