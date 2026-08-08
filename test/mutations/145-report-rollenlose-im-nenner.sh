#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_RollenloseCallsNichtImNenner
#
# Nimmt die rollenlosen Tool-Calls in den Nenner der Splitting-Regel auf.
#
# Damit verteilt der Sammelposten teilweise auf sich selbst: die Calls ohne
# Rolle sind genau der Strom, dessen Token verteilt werden sollen. Der Schaden
# ist lautlos — die Summe bleibt erhalten, sie wandert nur an die falschen
# Rollen, und je groesser der rollenlose Anteil, desto staerker verduennt er
# jede reale Rolle. Die Entscheidung "rollenlose Calls NICHT im Nenner" steht
# als Teil der Festlegung in spec/spezifikation.md §5.
#
# Faerbt zusaetzlich TestAggregiere_SammelpostenWirdAnteiligVerteilt rot: auch
# dessen Bestand traegt rollenlose Calls. Erwartet wird der Fall oben.
set -euo pipefail
sed -i 's@^\tif s.AgentRole != "" \&\& s.Tool != "" {$@\tif s.Tool != "" {@' internal/report/report.go
