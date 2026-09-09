#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_KeineKommentarHilfenImEmittiertenSatz
#
# Der StripCommentHints-Aufruf in planTemplates faellt weg -> jedes emittierte
# Singleton traegt seine HTML-Kommentar-Hilfen aus dem vendored Satz weiter
# (Schritt 5 der Kopier-Prozedur, README.md §Verwendung, bleibt unvollzogen).
# body wird weiter genutzt (naechste Zeile liest ihn) -> kompiliert.
set -euo pipefail
sed -i '/body = StripCommentHints(body)/d' internal/emit/templates.go
