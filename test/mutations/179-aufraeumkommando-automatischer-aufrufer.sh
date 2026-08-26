#!/usr/bin/env bash
# files: internal/emit/templates/enforce/erfassung.mk
# expect: TestErfassungFragment_KeinAutomatischerAufrufer
# verify: test-go
#
# HAENGT DAS AUFRAEUM-KOMMANDO IN EINE PREREQUISITE-KETTE: wer den Bericht ruft, loescht
# vorher den Bestand.
#
# HIER IST DAS GEGENBEISPIEL DIE AUTOMATIK, NICHT DAS FEHLEN. Ein Waechter, der nur
# prueft, dass es das Ziel gibt, bliebe hier gruen — und ein Adopter verloere seinen
# Bestand beim Lesen. LH-FA-10 §Aufbewahrung schliesst genau das aus: "eine automatische
# Rotation ist nicht Teil der Zusage — ein Loeschpfad in einem fail-open-Hook ueber
# fremden Daten waere der teurere Fehlerfall". Der Fehler ist unumkehrbar, und die Kette
# steht nicht in `gates`: kein Gate-Waechter faellt darueber.
set -euo pipefail
sed -i 's@^span-report: ## @span-report: span-clean ## @' internal/emit/templates/enforce/erfassung.mk
