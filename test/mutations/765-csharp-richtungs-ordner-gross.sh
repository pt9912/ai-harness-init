#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestCsharpHexslice_RichtungsOrdnerKlein
#
# Das Richtungs-Segment inbound wird gross geschrieben, in Verzeichnissen, Namensraeumen und Globs
# zugleich: Renderer und Config bleiben zueinander konsistent, TestArchGateConfig_CsharpGlobsMatchRenderedDirs
# und der Namensraum-Test bleiben gruen. a-check zieht das Segment nur kleingeschrieben ab, port-locality
# entfiele fuer den Port (ADR-0097 Festlegung 1 und 2); der Text-Waechter haelt die kleine Schreibweise.
set -euo pipefail
sed -i -E 's#Ports([./])inbound#Ports\1Inbound#g' internal/gen/csharp_hexslice.go
