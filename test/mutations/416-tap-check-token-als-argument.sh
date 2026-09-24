#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: token: ein Sentinel-Token steht in keiner Argumentliste und keiner Ausgabe
# verify: test-bats
#
# BRINGT DAS TOKEN ZUSAETZLICH IN DIE KOMMANDOZEILE: curl bekommt neben `-H @<Datei>` einen
# zweiten Header `-H "Authorization: Bearer <Token>"`; die Umgebungsvariable bleibt dafuer
# stehen. Die Kopfdatei bleibt unveraendert, ihre Zeilen des Falls bleiben gruen: das Token
# steht danach allein in der Prozess-Kommandozeile.
# Rot faerbt der Fall an der Zeile `nirgends`, die die Argumentliste des curl-Stubs liest.
set -euo pipefail
sed -i -e 's|^\t\tset -- "[$]@" -H "@[$]hdr"$|\t\tset -- "\x24@" -H "@\x24hdr" -H "Authorization: Bearer \x24TAP_TOKEN"|' -e '/^unset TAP_TOKEN$/d' harness/tools/tap-nachzug-nutzlast.sh
