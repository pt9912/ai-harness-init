#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpGlobsMatchRenderedDirs
#
# Allein die outbound-Port-Globs der C#-.a-check.yml tragen das Richtungs-Segment gross, der Renderer
# schreibt die Verzeichnisse klein: der Glob trifft kein gerendertes Verzeichnis, a-check sahe die
# Port-Dateien nicht (ADR-0097 Festlegung 2). Die Mutation beruehrt nur die Config-Zeilen (Muster
# `/**`), nicht die Pfade des Renderers.
set -euo pipefail
sed -i -E 's#(Ports/)outbound(/\*\*)#\1Outbound\2#g' internal/gen/csharp_hexslice.go
