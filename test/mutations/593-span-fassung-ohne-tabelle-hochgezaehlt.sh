#!/usr/bin/env bash
# files: internal/span/ruleversion.go
# expect: TestCurrentRuleVersionIsTheLastSpecFassung
#
# ZAEHLT DIE FASSUNG HOCH, OHNE SIE IN DER SPEZIFIKATION ZU BESCHREIBEN. Der Traeger
# schreibt dann eine Fassung, die die Fassungs-Tabelle in spec/spezifikation.md §5 nicht
# fuehrt (SPEC-094) — ein Leser saehe eine Zahl ohne Bedeutung. Der Anker nimmt jede
# Fassung, nicht eine bestimmte: er bleibt beim naechsten Bedeutungswechsel gueltig.
set -euo pipefail
sed -i -E 's/^const CurrentRuleVersion = ([0-9]+)$/const CurrentRuleVersion = \1 + 1/' internal/span/ruleversion.go
