#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_MatchesSkeleton
#
# Laesst den slice-lokalen Port-Glob der emittierten .a-check.yml ins Leere zeigen
# (greet/ports -> greet/nirgends). Die Config beschriebe dann eine Schicht, die das
# generierte Skelett nicht traegt: notifier.go faellt unter die App-Schicht statt unter
# ports, und der Glob deckt keine Datei mehr. Das ist die Drift-Klasse, die die
# ADR-0009-Fitness-Function fangen soll (Kopplung Layout <-> Config).
set -euo pipefail
sed -i 's|application/example/greet/ports/\*\*|application/example/greet/nirgends/**|' internal/gen/golang.go
