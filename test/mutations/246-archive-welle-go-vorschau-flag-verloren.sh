#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestParseArchiveWelleGewinntDenSchalterAusDemArgument
# verify: test-go
#
# NIMMT DEM SCHALTER SEINEN WEG IN DEN PARAMETER: `--vorschau` wird weiter als
# gueltiges Flag angenommen — kein Exit 2, keine Meldung —, aber der Wert, den
# der Parser daraus gewinnt, ist konstant falsch. Der Aufrufer setzt den
# Schalter, der Guard sieht ihn nie, der Lauf archiviert.
#
# Das ist NICHT Fall 242. Der nimmt dem Guard seine Wirkung (`if vorschau` wird
# `if false`) und wird an einem Fall rot, der `vorschau` als PARAMETER uebergibt.
# Hier bleibt der Guard heil; unterbrochen ist die Strecke davor — die einzige
# Stelle, an der ein Kommandozeilen-Argument zu diesem Parameter wird. Ein Fall,
# der den Parameter direkt setzt, kann diese Mutation nicht sehen.
#
# Rot wird sie am Parser-Fall (drei Argument-Felder, zwei Erwartungen) und
# zusaetzlich an der Strecken-Messung
# TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig, die dann schreibt.
set -euo pipefail
sed -i 's/^\t\t\tvorschau = true$/\t\t\tvorschau = false/' cmd/ai-harness-init/archive_welle.go
