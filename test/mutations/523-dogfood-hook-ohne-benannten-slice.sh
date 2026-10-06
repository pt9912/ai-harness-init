#!/usr/bin/env bash
# files: harness/tools/commit-msg-traceability.sh
# expect: traeger: ein benannter Slice (MR-057-Form) und sonst keine Kennung wird angenommen
# verify: test-bats
#
# DER DOGFOOD-HOOK PRUEFT DIE ZEILE `named_slice=` NICHT MEHR: die Bedingung der Schleife
# kehrt zur Nummernform in `patterns=` zurueck. Ein Commit mit benanntem Slice und sonst
# keiner Kennung bricht am Hook; die Nummernform bleibt gruen. Die Zeile `named_slice=`
# selbst bleibt stehen. Die Mutation faerbt vier Tests rot: den Fall des benannten Slice
# und "a slice-wise fix" (commit-msg-hook.bats 8 und 10), die Kopplung an die Config
# (commit-msg-hook.bats 15) und die Gleichheit mit der emittierten Fassung
# (commit-msg-emission.bats 16). Setzt man den Fall des benannten Slice aus, bleiben die
# drei uebrigen rot; der Fall bindet die Verwendung darum nicht allein.
#
# DER PATCH SITZT AUF DER AUSFUEHRENDEN ZEILE (Bedingung), nicht auf der Prosa im Kopf.
set -euo pipefail
sed -i "s@\(\[\[ \"\$line\" =~ \$patterns \]\]\) || \[\[ \"\$line\" =~ \$named_slice \]\]@\1@" harness/tools/commit-msg-traceability.sh
