#!/usr/bin/env bash
# files: internal/emit/templates/enforce/record-gates.sh
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# EINE EMITTIERTE VORLAGE TRAEGT EINE SPEC-KENNUNG, DIE IM ZIEL NICHT AUFLOEST: der Kopf
# von record-gates.sh nennt SPEC-024. Das Ziel fuehrt keine Spezifikation mit dieser
# Nummer; der Waechter liest die reale Emission jeder Lauf-Variante und meldet die Datei:
#   tools/harness/record-gates.sh: emittiert SPEC-024 — erlaubt:
# Der Fall bindet die Form SPEC-NNN im Kennungs-Muster (LH-QA-01).
set -euo pipefail
sed -i 's/^# HEAD-STEMPEL: /# HEAD-STEMPEL (SPEC-024): /' internal/emit/templates/enforce/record-gates.sh
