#!/usr/bin/env bash
# files: internal/emit/templates/enforce/record-gates.sh
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# EINE EMITTIERTE VORLAGE TRAEGT EINE KENNUNG, DIE IM ZIEL NICHT AUFLOEST: der Kopf von
# record-gates.sh nennt ADR-0999. Das Ziel fuehrt kein ADR-Register mit dieser Nummer;
# der Waechter liest die reale Emission jeder Lauf-Variante und meldet die Datei:
#   tools/harness/record-gates.sh: emittiert ADR-0999 — erlaubt:
# Der Fall bindet die Richtung "Fund ausserhalb der Ausnahme-Liste" (LH-QA-01).
set -euo pipefail
sed -i 's/^# HEAD-STEMPEL: /# HEAD-STEMPEL (ADR-0999): /' internal/emit/templates/enforce/record-gates.sh
