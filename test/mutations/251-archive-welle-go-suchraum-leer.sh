#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleEchtSperrtAmHaengendenVerweis
# verify: test-go
#
# VERWIRFT DIE ANTWORT VON `git ls-files`: der Prozess laeuft weiter, sein Fehler
# wird weiter durchgereicht — nur der Suchraum, in dem beide Zweige nach
# Verweisen suchen, ist danach leer. Damit faellt der Haenger-Schutz: ein
# Review-Report, auf den spec/lastenheft.md noch zeigt, wird geloescht, und der
# Verweis in Rang 1 der Source Precedence zeigt ins Leere.
#
# Das ist NICHT Fall 233. Der verengt den Suchraum in internal/archive um
# docs/reviews/** und wird an einem Fall rot, der die Datei-Liste als WERT
# uebergibt. Hier bleibt die Logik heil; unterbrochen ist die Strecke aus der
# Aussenwelt in sie hinein.
#
# Der schreibende Lauf am sperrenfreien Baum bleibt gruen — dort traegt keine
# Datei einen Verweis. Genau daran ist die Mutation zu erkennen: sie nimmt keine
# Faehigkeit weg, sondern eine Vorpruefung.
set -euo pipefail
sed -i 's|^\t\tdateien:    gitLsFiles,$|\t\tdateien:    func(root string) ([]string, error) { _, err := gitLsFiles(root); return nil, err },|' \
	cmd/ai-harness-init/archive_welle.go
