#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen
# verify: test-go
#
# SETZT DIE ZWEI STELLEN IM ANWEISUNGSSATZ AUF DIE HANDARBEIT ZURUECK: der
# Lifecycle-Wechsel steht danach wieder als `git mv` da.
#
# Das ist der Zustand, den dieser Slice aufloest: der Move macht Pfade tot, und
# die Reparatur ist Handarbeit, die niemand anweist. Der Text bleibt dabei
# syntaktisch intakt — er nennt nur die Operation, die den Verweis-Nachzug nicht
# faehrt, und keine Zeile des Plans faellt darueber.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der emittierte
# Anweisungssatz, den `emit.CommandFile` liefert. Ein Lauf im gebootstrappten
# Repo zeigt dieselbe Zeile erst nach einem `full-smoke` samt Bootstrap.
set -euo pipefail
sed -i 's/make slice-mv/git mv/g' internal/emit/templates/commands/implement-slice.md
