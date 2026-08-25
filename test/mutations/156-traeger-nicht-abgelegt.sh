#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_ErfassungLiegtMitDemTraeger
#
# LAESST DEN TRAEGER WEG: die Ablage meldet Erfolg und kopiert nichts.
#
# Der Waechter misst den Traeger am gebootstrappten ZIEL, nicht an einer Liste im Code —
# er liegt gitignored und steht in keiner Emit-Pfad-Liste. Bliebe er unter dieser
# Mutation gruen, waere die Anwesenheits-Zusage aus ADR-0022 Festlegung 1 eine Aussage
# ueber den Emitter statt ueber das Ziel.
set -euo pipefail
sed -i 's@^\treturn writeCarrier(targetDir, rel, in)$@\treturn nil@' internal/emit/enforce.go
