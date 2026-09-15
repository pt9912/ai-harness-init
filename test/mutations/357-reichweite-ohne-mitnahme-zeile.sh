#!/usr/bin/env bash
# files: internal/emit/templates/enforce/hooks-install.mk
# expect: TestHooksInstallFragment_TraegtDieReichweite
# verify: test-go
#
# NIMMT DEM AKTIVIERUNGS-FRAGMENT DIE MITNAHME: genannt bleiben die zwei Grenzen des
# Traegers und die Zusage-Haelfte, die er nicht prueft — kein Wort sagt danach, dass er
# die Commits der Repo-Werkzeuge mitnimmt und abbricht, solange deren Messages keine
# Kennung aus der Menge tragen.
#
# Das ist die Reichweite in der anderen Richtung: ein Traeger, dessen Reichweite nur als
# Zaun beschrieben ist, liest sich als Hindernis fuer Agenten-Commits, waehrend er die
# Commits der Repo-Werkzeuge mitnimmt. Beide Richtungen gehoeren neben die Zusage.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Text des
# Fragments, nicht seine Wirkung. Ein `make full-smoke` liest dieselbe Zeile im
# gebootstrappten Ziel, kostet aber den vollen E2E-Lauf ueber drei Varianten.
set -euo pipefail
sed -i '/^# WAS ER MITNIMMT\./,/an seinem eigenen Waechter\.$/d' internal/emit/templates/enforce/hooks-install.mk
