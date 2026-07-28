#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_HexagonalMatchesSkeleton
#
# Laesst den Schicht-Glob der treibenden Adapter ins Leere zeigen (driving -> nirgends),
# waehrend der Renderer weiter nach internal/adapter/driving/ schreibt. Die emittierte
# Config beschriebe dann eine Schicht, die das Skelett nicht traegt, und cli.go fiele
# unter GAR KEINE Schicht: a-check laeuft gruen ueber einem Loch im Pruefbereich, und
# genau dort greift auch `lateral-adapter` nicht mehr (LH-QA-01). Das ist die
# Drift-Klasse Layout <-> Config, die Fall 68 fuer hexslice haelt.
set -euo pipefail
sed -i 's|globs: \["internal/adapter/driving/\*\*"\]|globs: ["internal/adapter/nirgends/**"]|' internal/gen/golang.go
