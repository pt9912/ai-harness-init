#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: full-smoke: FEHLER — das emittierte C#-Arch-Gate bleibt bei einem fremden Port-using im Handler gruen (port-locality an Handler.cs bleibt aus
# verify: full-smoke
#
# Das Richtungs-Segment outbound wird gross geschrieben, in Verzeichnissen, Namensraeumen und Globs
# zugleich (Renderer und Config konsistent: kein Glob-gegen-Pfad-Test faerbt). a-check zieht das
# Richtungs-Segment nur kleingeschrieben ab: die outbound-Port-Globs erreichen den App-Baum nicht,
# port-locality entfaellt, das Gate bleibt bei einem fremden Port-using im Handler gruen. Erst der
# Lauf-Zahn in der Stufe "add-lang csharp apps/csharphexslice --arch hexslice" in
# harness/tools/full-smoke.sh (zweite Slice, fremder using im Handler) faerbt das (ADR-0097).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i -E 's#Ports([./])outbound#Ports\1Outbound#g' internal/gen/csharp_hexslice.go
