#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_TrenntDieFassungen
#
# ZAEHLT JEDE ZEILE UNTER DER FASSUNG DES LESERS statt unter der, die sie traegt. Der
# Bericht wiese dann den ganzen Bestand als laufende Fassung aus, auch die Zeilen ohne
# `rule_version` — genau die Vermischung, die SPEC-095 ausschliesst.
set -euo pipefail
sed -i 's/^\t\t\tb.Fassungen\[s.RuleVersion\]++$/\t\t\tb.Fassungen[span.CurrentRuleVersion]++/' internal/report/report.go
