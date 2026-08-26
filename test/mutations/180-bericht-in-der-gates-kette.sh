#!/usr/bin/env bash
# files: internal/emit/templates/enforce/enforce.mk
# expect: TestErfassung_NichtInDerGatesKette
# verify: test-go
#
# HAENGT DEN BERICHT IN DIE GATES-KETTE DES ZIELS: `record-gates` bekommt span-report als
# Prerequisite, und damit faehrt jedes `make gates` des Adopters den Leser mit.
#
# Der Ort ist mit Absicht das ENFORCE-Fragment und nicht das Fragment des Berichts: die
# Verdrahtung entsteht typisch dort, wo die Kette gepflegt wird, nicht dort, wo das Ziel
# definiert ist — und ein Waechter, der nur seine eigene Datei liest, saehe sie nie.
# Danach ist ein Bericht ein Gate ueber leerem Pruefbereich (LH-QA-01): er prueft nichts
# und faerbt nichts rot, steht aber im Weg jedes Gate-Laufs.
set -euo pipefail
sed -i 's@^record-gates: ## @record-gates: span-report ## @' internal/emit/templates/enforce/enforce.mk
