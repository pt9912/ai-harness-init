#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: jedes woertliche Zitat der Spezifikation in einem Kommentar steht in spec/spezifikation.md
# verify: test-bats
#
# HAENGT EINEN KOMMENTAR AN, DER DIE SPEZIFIKATION MIT EINEM ZITAT NENNT, DAS DORT NICHT
# STEHT: das Zitat laeuft ueber zwei Kommentarzeilen und schreibt „Unterscheidbar" klein,
# die Spezifikation schreibt es gross. Gebunden ist damit dreierlei zugleich — die
# Verbindung der Folgezeilen, der Zeilen-Praefix `//` und die Gross-/Kleinschreibung.
# Die Datei bleibt uebersetzbar: nur eine Kommentarzeile kommt dazu.
set -euo pipefail
printf '%s\n' \
  '// Die Spalte `spawned_role` in spec/spezifikation.md sagt: „unterscheidbar bleibt es am' \
  '// Pflichtfeld `tool`".' >> internal/span/emit.go
