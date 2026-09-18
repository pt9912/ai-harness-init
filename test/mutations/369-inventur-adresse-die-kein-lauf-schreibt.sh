#!/usr/bin/env bash
# files: internal/emit/baumaussage.go
# expect: TestTraegerInventur_JedeGenannteAdresseEntstehtImZiel
# verify: test-go
#
# SCHICKT EINE ZELLE AUF EINEN ORT, AN DEM DIE DATEI NICHT LIEGT: die Roadmap entsteht im
# Ziel unter docs/plan/planning/in-progress/, nicht flach unter docs/plan/planning/.
#
# WAS DAS MISST: die POSITIVE Richtung der Inventur. Die Abwesenheits-Richtung und der
# Nenner sind anderswo bewacht; ohne diesen Zahn duerfte jede Zelle mit dem Wert "Traeger
# kommt mit" auf einen Pfad zeigen, den kein Lauf schreibt — der Wert bliebe richtig, die
# Adresse falsch, und der Adopter suchte an einer Stelle, an der nichts liegt.
#
# Die Mutation ist die reale Form des Befundes: der Ort, den man vermutet, statt dem, den
# singletonTarget vergibt.
set -euo pipefail
sed -i 's@docs/plan/planning/in-progress/roadmap.md@docs/plan/planning/roadmap.md@' internal/emit/baumaussage.go
