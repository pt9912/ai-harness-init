#!/usr/bin/env bash
# files: internal/emit/templates/commands/close-welle.md
# expect: TestEmittierteDokumente_NurInitInvarianteZiele
# verify: test-go
#
# BENENNT DAS ZIEL IN DER ANLEITUNG UM: sie nennt danach `make archiv-welle`,
# waehrend das Fragment `archive-welle` fuehrt.
#
# Das ist die Richtung, die den Adopter trifft, der das Ziel umbenennt: die
# Anleitung ist skip-if-present und bleibt stehen, das Fragment ist konvergent und
# kommt bei jedem Bootstrap mit seinem eigenen Namen zurueck. Der Aufruf endet
# danach laut (make kennt den Namen nicht) — eine Anleitung, die auf ein Ziel
# zeigt, das es nicht gibt, ist die Zusage, gegen die dieser Fall steht.
#
# Er trifft die TEXT-Haelfte; die Lauf-Haelfte derselben Klasse misst
# harness/tools/full-smoke.sh im gebootstrappten Ziel an einem Aufruf ueber einem
# Namen, den kein Fragment fuehrt.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der emittierte
# Dokument-Satz gegen die Ziele, die die Fragmente definieren — beide Seiten
# gelesen, keine gepflegte Liste. Die Lauf-Haelfte derselben Klasse steht daneben
# in harness/tools/full-smoke.sh und kostet einen Bootstrap-Lauf.
set -euo pipefail
sed -i 's/make archive-welle WELLE=<welle-id>/make archiv-welle WELLE=<welle-id>/' \
	internal/emit/templates/commands/close-welle.md
