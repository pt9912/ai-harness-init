#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_MatchesSkeleton
#
# Laesst den slice-lokalen Port-Glob der emittierten .a-check.yml ins Leere zeigen
# (greet/ports/inbound -> greet/nirgends/inbound). Die Config beschriebe dann eine
# Schicht, die das generierte Skelett nicht traegt: greet.go faellt unter die App-
# Schicht statt unter ports_inbound, und der Glob deckt keine Datei mehr. Das ist die
# Drift-Klasse, die die ADR-0009-Fitness-Function fangen soll (Kopplung Layout <->
# Config). Der Port-Glob traegt das Richtungs-Segment als Glob-Literal
# (…/ports/inbound/**), und genau dieses Literal zeigt die Mutation ins Leere.
set -euo pipefail
sed -i 's|greet/ports/inbound/\*\*|greet/nirgends/inbound/**|' internal/gen/golang.go
