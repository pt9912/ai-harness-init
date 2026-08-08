#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_SpawnSpanZaehltNichtAlsToolCall
#
# Nimmt den Werkzeug-Filter aus dem Schluessel der Splitting-Regel: ein
# `SubagentStart`-Span zaehlt dann als Tool-Call.
#
# Er ist keiner. Das Ereignis feuert je SPAWN und traegt weder `tool_name` noch
# `tool_use_id` (spec/spezifikation.md §5). Ohne den Filter verschiebt jeder
# Spawn den Schluessel zugunsten der Rolle, die ihn ausgeloest hat — je mehr eine
# Rolle delegiert, desto mehr Sammelposten bekaeme sie zugeteilt, ohne dafuer
# einen einzigen Tool-Call mehr gemacht zu haben. Der Schaden ist lautlos: die
# Summe stimmt, die Verteilung nicht.
set -euo pipefail
sed -i 's@^\tif s.AgentRole != "" \&\& s.Tool != "" {$@\tif s.AgentRole != "" {@' internal/report/report.go
