#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf
# verify: test-go
#
# NIMMT DEN HOOK AUS DEM EMIT: das Aktivierungs-Fragment setzt danach core.hooksPath
# auf ein Verzeichnis, in dem der Bootstrap nichts ablegt, und der Traeger fehlt im
# Ziel ganz.
#
# Das trifft die Zusage, die Traeger, Pruefung und Fragment zusammen halten: der
# mitemittierte Anweisungssatz nennt den Hook als den Ort, an dem die Kennungs-Regel
# durchgesetzt wird. Ohne ihn zeigt das Fragment auf ein Programm, das es nicht gibt
# (LH-QA-01), und `make hooks-install` bricht an seiner eigenen Pruefung ab.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Bestand nach
# einem Emit in ein leeres Zielverzeichnis. Ein `make full-smoke`-Lauf faende denselben
# Fehler ueber die Kette des gebootstrappten Repos; sein Preis ist ein Docker-Bau je
# Sprache.
set -euo pipefail
sed -i '/^\t\tcommitMsgHookFile(),$/d' internal/emit/enforce.go
