#!/usr/bin/env bash
# files: internal/span/ruleversion.go
# expect: TestCurrentRuleVersionIsTheLastSpecFassung
#
# ZAEHLT DIE FASSUNG HOCH, OHNE SIE IN DER SPEZIFIKATION ZU BESCHREIBEN. Der Traeger
# schreibt dann eine Fassung, die die Fassungs-Tabelle in spec/spezifikation.md §5 nicht
# fuehrt (SPEC-094) — ein Leser saehe eine Zahl ohne Bedeutung.
set -euo pipefail
sed -i 's/^const CurrentRuleVersion = 4$/const CurrentRuleVersion = 5/' internal/span/ruleversion.go
