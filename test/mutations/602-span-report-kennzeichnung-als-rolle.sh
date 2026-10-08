#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_KennzeichnungIstKeineRolle
#
# Die Auswertung prueft nur `""`: ein Tool-Call mit der Kennzeichnung `nicht bekannt:
# agent_type` zaehlt als eigene Rolle im Nenner der Splitting-Regel (SPEC-044, SPEC-098).
# Der Anker steht repo-weit genau einmal.
set -euo pipefail
sed -i 's@s.AgentRole != "" && !span.IsNotKnown(s.AgentRole) && s.Tool != ""@s.AgentRole != "" \&\& s.Tool != ""@' internal/report/report.go
