#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: gruen: ein benannter Slice (slice-<kennung>) wird angenommen, die Nummernform ebenso
# verify: test-bats
#
# DIE EMITTIERTE ZEILE `patterns=` VERLIERT DIE NAMENS-FORM: sie fuehrt danach nur noch
# `slice-[0-9]+`. Ein Commit mit benanntem Slice faellt am Traeger des Ziels, die
# Nummernform bleibt gruen — der Fall `rot` und die Obermenge (Dogfood fuehrt dasselbe
# Muster) bleiben dabei gruen, nur der Fall des benannten Slice bindet die Zeile.
#
# DER PATCH SITZT AUF DER AUSFUEHRENDEN ZEILE (Zuweisung), nicht auf der Prosa im Kopf.
set -euo pipefail
sed -i "s@^\(patterns=.*\)|slice-\[a-z\]\[a-z0-9-\]\*)'@\1)'@" internal/emit/templates/enforce/commit-msg-traceability.sh
