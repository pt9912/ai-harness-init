#!/usr/bin/env bash
# files: internal/emit/readme.go
# expect: TestTemplates_KeineKommentarHilfenImEmittiertenSatz
#
# Die zweite, gleichrangige Verdrahtung von StripCommentHints (RootReadme,
# readme.go:44) faellt weg -> die Root-README traegt ihre HTML-Kommentar-
# Hilfen aus project-readme.template.md weiter (Schritt 5 der Kopier-Prozedur
# bleibt fuer diesen Pfad unvollzogen). Der erste Aufruf entfaellt, der Rest
# der Kette (stampName/NeutralizeMakeClaims/NeutralizePlaceholderLinks) bleibt
# unberuehrt -> kompiliert.
set -euo pipefail
sed -i 's/body := StripCommentHints(stampName(StripHintBlock(string(content)), name))/body := stampName(StripHintBlock(string(content)), name)/' internal/emit/readme.go
