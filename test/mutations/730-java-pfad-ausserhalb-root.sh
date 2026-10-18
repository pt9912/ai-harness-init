#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: TestArchGateConfig_JavaResolution
#
# Die gerenderten Java-Pfade liegen unter src/main/java statt src/main/java/app, ohne dass
# die Config mitzieht: der Root der Config traefe keine Produktionsdatei (Pfad-gegen-Config-
# Kopplung, ADR-0094 Festlegung 4).
set -euo pipefail
sed -i 's|srcMain: "src/main/java/app/"|srcMain: "src/main/java/"|' internal/gen/java.go
