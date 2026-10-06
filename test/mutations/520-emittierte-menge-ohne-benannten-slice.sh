#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: gruen: ein benannter Slice (slice-<kennung>) wird angenommen, die Nummernform ebenso
# verify: test-bats
#
# DIE EMITTIERTE ZEILE `named_slice=` VERLIERT DIE NAMENS-FORM: sie fuehrt danach nur noch
# die Wortgrenze und `slice-` ohne Namensrumpf. Ein Commit mit benanntem Slice faellt am
# Traeger des Ziels, die Nummernform bleibt gruen — der Fall `rot` und die Obermenge
# (Dogfood fuehrt dasselbe Nummern-Muster) bleiben dabei gruen, nur der Fall des benannten
# Slice bindet die Zeile.
#
# DER PATCH SITZT AUF DER AUSFUEHRENDEN ZEILE (Zuweisung), nicht auf der Prosa im Kopf.
set -euo pipefail
sed -i "s@^\(named_slice='.*\)slice-\[a-z\]\[a-z0-9-\]\*'@\1slice-[0-9]+'@" internal/emit/templates/enforce/commit-msg-traceability.sh
