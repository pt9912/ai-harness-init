#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet
#
# DIE MELDUNG NENNT NUR NOCH DAS VERZEICHNIS: der belegte Pfad bleibt stehen und wird genannt,
# aber der Adopter erfaehrt nicht, was dann gilt — dass die Dateien des Verzeichnisses im Klon
# mit core.autocrlf=true CRLF tragen, solange seine Datei die Zeile nicht fuehrt. Ohne die Aussage
# ist die Meldung eine Ortsangabe.
set -euo pipefail
sed -i 's|"/ im Klon mit core.autocrlf=true CRLF."|"/"|' internal/emit/zeilenenden.go
