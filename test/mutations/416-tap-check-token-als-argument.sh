#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: token: ein Sentinel-Token steht in keiner Argumentliste und keiner Ausgabe
# verify: test-bats
#
# BRINGT DAS TOKEN IN DIE KOMMANDOZEILE: curl bekommt den Bearer-Header als
# `-H "Authorization: Bearer <Token>"` statt als `-H @<Datei>`; die Umgebungsvariable
# bleibt dafuer stehen. Das Token steht danach in der Prozess-Kommandozeile.
# Rot faerbt der Fall, dessen curl-Stub seine Argumentliste aufzeichnet.
set -euo pipefail
sed -i -e 's|^\t\tset -- "[$]@" -H "@[$]hdr"$|\t\tset -- "\x24@" -H "Authorization: Bearer \x24TAP_TOKEN"|' -e '/^unset TAP_TOKEN$/d' harness/tools/tap-nachzug-nutzlast.sh
