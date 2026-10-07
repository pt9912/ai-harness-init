#!/usr/bin/env bash
# files: internal/emit/werkzeugindex.go
# expect: TestWerkzeugIndex_ZeileJeWerkzeugTargetDisjunkt
# verify: test-go
#
# STREICHT DEN DISJUNKT-FILTER DES WERKZEUG-TEILS.
#
# Danach fuehrt harness/mk/ai-harness-init.md auch die Targets, die harness/README.md schon als
# Tabellenzeile traegt — ein Target in zwei Teilen, das der Sensor gegen die Vereinigung nicht
# sieht (Kurs v6.16.0, grundlagen-harness-dateien.md). Der Test haelt den vollstaendigen
# Zeilen-Bestand gegen die erwartete Liste.
set -euo pipefail
sed -i '/^\t\tif imRepoIndex\[n\] {$/,/^\t\t}$/d' internal/emit/werkzeugindex.go
