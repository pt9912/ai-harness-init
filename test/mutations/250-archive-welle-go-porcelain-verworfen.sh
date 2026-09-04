#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum
# verify: test-go
#
# VERWIRFT DIE ANTWORT VON `git status --porcelain`: der Prozess laeuft weiter,
# sein Fehler wird weiter durchgereicht — nur der Text, aus dem die
# Sauberkeits-Sperre entsteht, ist danach leer. Die Vorpruefung meldet "Sperren:
# keine", und der schreibende Lauf zieht nicht committete Arbeit ins Archiv-Zip,
# waehrend der Move-Commit den sauberen Blob traegt.
#
# Das ist NICHT Fall 232. Der verengt die Sperren-LOGIK in internal/archive auf
# getrackte Dateien und wird an einem Fall rot, der ihr die porcelain-Ausgabe als
# WERT gibt. Hier bleibt die Logik heil; unterbrochen ist die Strecke aus der
# Aussenwelt in sie hinein — die vier Felder von echterEingang(), die kein Fall
# mit eigener Eingangs-Attrappe je beruehrt.
set -euo pipefail
sed -i 's|^\t\tporcelain:  gitStatusPorcelain,$|\t\tporcelain:  func(root string) (string, error) { _, err := gitStatusPorcelain(root); return "", err },|' \
	cmd/ai-harness-init/archive_welle.go
