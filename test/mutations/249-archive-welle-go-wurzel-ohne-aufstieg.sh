#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum
# verify: test-go
#
# NIMMT DER VERDRAHTUNG DEN AUFSTIEG ZUR REPO-WURZEL: das Feld `wurzel` liefert
# danach das Arbeitsverzeichnis selbst statt der Wurzel darueber. Die Signatur
# ist dieselbe, der Uebersetzer sieht keinen Unterschied — und wer das Kommando
# aus der Repo-Wurzel ruft, merkt auch keinen.
#
# Sichtbar wird es nur an einem Lauf aus einem UNTERVERZEICHNIS: dort liest die
# Einsammel-Stufe unter dem falschen Pfad, findet done/ nicht und der Lauf endet
# als Laufzeit-Fehler, statt die Sperre zu nennen, die dort steht. Kein Fall mit
# eigener Eingangs-Attrappe kann das sehen — die setzt die Wurzel selbst.
set -euo pipefail
sed -i 's/^\t\twurzel:     repoWurzel,$/\t\twurzel:     os.Getwd,/' \
	cmd/ai-harness-init/archive_welle.go
