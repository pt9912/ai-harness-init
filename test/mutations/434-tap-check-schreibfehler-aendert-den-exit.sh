#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: stderr nicht beschreibbar: der Exit bleibt die Klasse des Skripts
# verify: test-bats
#
# LAESST EINEN SCHREIBFEHLER AUF STDERR DEN EXIT AENDERN: melde faengt das Scheitern von printf
# nicht mehr ab, und ein geschlossenes oder volles stderr macht aus Exit 2 den Exit 1.
# Rot faerbt der Fall, der stderr auf /dev/full und geschlossen stellt und Exit 2 liest.
set -euo pipefail
sed -i '/^melde() {$/,/^}$/s| \|\| :$||' harness/tools/tap-nachzug.sh
