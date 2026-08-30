#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: an der Kante haengen genau die erwarteten Checks
#
# Die Kante bleibt stehen, aber ihre Liste wird auf die ERSTE Voraussetzung gekuerzt:
# `record-gates: <a> <b> … ## …` -> `record-gates: <a> ## …`. Neun Checks fallen damit
# aus `make gates` heraus, und der Stempel deckt einen Baum, ueber den sie nie geurteilt
# haben — der Stop-Hook gibt einen Abschluss frei, den kein Check gesehen hat.
#
# Das ist die Form, in der das Loch ohne sichtbaren Bruch zurueckkommt: die Kante
# existiert weiter, kein Check steht daneben, und `gates` zieht den Nachweis — die drei
# aelteren Zusagen bleiben also gruen. Genau dafuer haengt die Erwartungsliste im
# Waechter.
#
# Das Muster kommt ohne die Namen der Checks aus (es haelt nur den ersten und loescht
# bis zum Hilfe-Kommentar) und wandert damit mit der Liste mit; greift es nicht mehr,
# meldet der Treiber "Mutation hat nicht gegriffen" statt still gruen zu bleiben.
set -euo pipefail
sed -i 's/^\(record-gates: [^ ]*\) [^#]*##/\1 ##/' Makefile
