#!/usr/bin/env bash
# files: harness/tools/commit-msg-traceability.sh
# expect: traeger: ein benannter Slice (MR-057-Form) und sonst keine Kennung wird angenommen
# verify: test-bats
#
# DER DOGFOOD-HOOK PRUEFT DIE ZEILE `named_slice=` NICHT MEHR: die Bedingung der Schleife
# kehrt zur Nummernform in `patterns=` zurueck. Ein Commit mit benanntem Slice und sonst
# keiner Kennung bricht am Hook; die Nummernform bleibt gruen. Die Zeile `named_slice=`
# selbst bleibt stehen — die Kopplungs-Faelle sehen die Mutation darum nicht, nur der
# Fall des benannten Slice bindet die Verwendung.
#
# DER PATCH SITZT AUF DER AUSFUEHRENDEN ZEILE (Bedingung), nicht auf der Prosa im Kopf.
set -euo pipefail
sed -i "s@\(\[\[ \"\$line\" =~ \$patterns \]\]\) || \[\[ \"\$line\" =~ \$named_slice \]\]@\1@" harness/tools/commit-msg-traceability.sh
