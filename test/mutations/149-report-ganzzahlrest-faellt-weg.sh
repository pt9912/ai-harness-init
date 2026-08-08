#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_GanzzahlRestGehtNichtVerloren
#
# Laesst den Rest der Ganzzahl-Division liegen: je Rolle faellt bis zu ein Token
# aus der Bilanz.
#
# Der Betrag ist klein und der Schaden trotzdem der gleiche wie bei den grossen:
# die Sammelposten-Zeile nennt einen Betrag als verteilt, den die Rollen-Zeilen
# nicht tragen. Wer beide gegenrechnet, findet eine Differenz und sucht sie im
# Bestand statt in der Rechnung.
set -euo pipefail
sed -i 's@^\t\tverteileRest(rollen, sammelposten)$@\t\t_ = sammelposten@' internal/report/report.go
