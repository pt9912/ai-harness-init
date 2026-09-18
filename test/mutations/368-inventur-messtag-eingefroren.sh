#!/usr/bin/env bash
# files: internal/emit/baumaussage.go
# expect: TestInventurMessTag_IstDerGefetchteStand
# verify: test-go
#
# LAESST DEN MESS-STAND DER INVENTUR HINTER DEM GEFETCHTEN TAG ZURUECK — die Form, in der
# ein Baseline-Sprung ihn real vergisst: der Baum wandert, die Ziffer im emittierten Block
# bleibt stehen.
#
# WAS DAS MISST: die Tabelle nennt Regelbloecke beim NAMEN und ist damit gegen genau einen
# Stand gemessen. Ein Mess-Tag, der nicht der gefetchte ist, sagt dem Adopter einen
# Bezugspunkt zu, den sein Baum nicht hat — die Drift waere unsichtbar statt nur
# ungeheilt (MR-033). Ohne diesen Zahn haenge die Kopplung an Aufmerksamkeit beim Sprung.
set -euo pipefail
sed -i 's@^const InventurMessTag = ".*"$@const InventurMessTag = "v0.0.0"@' internal/emit/baumaussage.go
