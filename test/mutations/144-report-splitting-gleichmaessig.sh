#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_SammelpostenWirdAnteiligVerteilt
#
# Verteilt den Sammelposten gleichmaessig auf alle Rollen statt anteilig nach
# Tool-Calls.
#
# Das ist die Festlegung selbst, nicht ihre Umsetzung: spec/spezifikation.md §5
# legt "anteilig nach Tool-Calls" fest und begruendet, warum die Alternative
# ausscheidet. Eine Gleichverteilung waere weiterhin eine Verteilung, sie ruhte
# nur auf nichts — und die Ausgabe naehme davon nichts zurueck, weil die
# Sammelposten-Zeile bloss den ANTEIL nennt, nicht den Schluessel.
set -euo pipefail
sed -i 's@^\t\t\tr.Zugeteilt = sammelposten \* toolCalls\[n\] / summeCalls$@\t\t\tr.Zugeteilt = sammelposten / int64(len(namen))@' internal/report/report.go
