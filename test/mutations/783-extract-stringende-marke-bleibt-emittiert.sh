#!/usr/bin/env bash
# files: internal/emit/templates/enforce/extract-command.awk
# expect: extract (beide Fassungen): wohlgeformtes JSON bleibt Exit 0 mit dem richtigen Befehl
#
# Entfernt in der Vorlage der emittierten Fassung das Zuruecksetzen der Marke `afterstr` hinter
# `: , } ]`: die Marke bleibt nach dem ersten String-Ende gesetzt, und jeder weitere String im
# selben JSON gilt als zwei Strings ohne Trenner. Der Extraktor ist dann zu streng
# (Falsch-Positiv): jeder Befehl mit Folgefeld endet in Exit 3.
#
# Rot wird in test/guard.bats die wohlgeformte Regressionsprobe der Schleife ueber beide
# Fassungen; sie meldet die gebrochene Fassung als `<pfad>: rc=3`.
#
# ANKER: die einzige Zeile, die genau `      afterstr = 0` (sechs Leerzeichen) traegt; die
# Initialisierung im Kopf des Scanners hat einen Kommentar dahinter und bleibt.
set -euo pipefail
sed -i '/^      afterstr = 0$/d' internal/emit/templates/enforce/extract-command.awk
