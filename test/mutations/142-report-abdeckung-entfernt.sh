#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_AbdeckungStehtDrin
#
# Nimmt der Abdeckungszahl ihre Bezugsmenge: die Ausgabe nennt dann nur noch, wie
# viele Laeufe Zaehler trugen, nicht mehr von wie vielen.
#
# Eine nackte Zahl ohne Bezugsmenge liest sich wie Vollstaendigkeit. Genau die
# Differenz ist die Aussage: ein Agent-Span ohne Zaehler zaehlt in den Bestand,
# aber nicht in die Bilanz — im Hintergrund ist das der Normalfall (erklaerte
# Abweichung in spec/spezifikation.md §5). Ohne beide Zahlen sieht der Leser eine
# unvollstaendige Erhebung fuer eine vollstaendige an.
set -euo pipefail
sed -i 's@Abdeckung: %d von %d Agent-Laeufen trugen Zaehler@Abdeckung: %d Agent-Laeufe trugen Zaehler@' internal/report/report.go
sed -i 's@b.MitZaehlern, b.AgentLaeufe)@b.MitZaehlern)@' internal/report/report.go
