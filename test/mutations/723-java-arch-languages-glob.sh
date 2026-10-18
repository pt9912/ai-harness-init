#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: TestArchGateConfig_JavaResolution
#
# Der languages-Glob der Java-.a-check.yml trifft keine .java-Datei: a-check liest dann
# keinen Import und das Gate bleibt ueber jeder Verletzung gruen (ADR-0094 Festlegung 4).
set -euo pipefail
sed -i 's|^  java: \["\*\*/\*\.java"\]$|  java: ["**/*.jav"]|' internal/gen/java_hexslice.go
