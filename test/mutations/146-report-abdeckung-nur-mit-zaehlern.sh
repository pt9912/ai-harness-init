#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_AbdeckungZaehltLaeufeOhneZaehler
#
# Zaehlt in die Bezugsmenge der Abdeckung nur noch die Laeufe, die Zaehler
# tragen — Zaehler und Bezugsmenge werden damit dieselbe Zahl.
#
# Die Abdeckung meldete dann immer "N von N", also dauerhaft Vollstaendigkeit,
# und zwar gerade dann, wenn sie fehlt: ein Hintergrund-Lauf traegt planmaessig
# keine Zaehler (spec/spezifikation.md §5, Abweichung 5) und verschwaende so aus
# beiden Seiten des Bruchs. Die Differenz IST die Aussage; ohne sie liest sich
# eine unvollstaendige Erhebung wie eine vollstaendige.
set -euo pipefail
sed -i 's@^\tb.AgentLaeufe++$@\t_ = 0@' internal/report/report.go
sed -i 's@^\tb.MitZaehlern++$@\tb.MitZaehlern++\n\tb.AgentLaeufe++@' internal/report/report.go
