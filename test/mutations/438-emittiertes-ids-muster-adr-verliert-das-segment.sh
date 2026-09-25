#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/ids_muster_adr
#
# Nimmt dem ADR-Muster von ids das optionale Bereichssegment: ADR-IDX-0004 im Fliesstext
# ist dann keine Kennung mehr und braucht keinen Link.
set -euo pipefail
sed -i "s|regex: 'ADR-[^']*'|regex: 'ADR-\\\\d{4}'|" internal/emit/templates/d-check.yml
