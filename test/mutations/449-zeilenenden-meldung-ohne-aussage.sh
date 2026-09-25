#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet
#
# DIE MELDUNG NENNT NUR NOCH DAS VERZEICHNIS: der belegte Pfad bleibt stehen und wird genannt, die
# Aussage steht nicht mehr in der Meldung — dass die Dateien des Verzeichnisses im Klon mit
# core.autocrlf=true CRLF tragen, solange die liegende Datei die Zeile nicht fuehrt. Die Meldung
# sagt, was gilt; der Test verlangt die Aussage neben dem Pfad.
set -euo pipefail
sed -i 's|"/ im Klon mit core.autocrlf=true CRLF."|"/"|' internal/emit/zeilenenden.go
