#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: vorab-tag: Exit 0 mit Vorab-Tag, Tap bleibt
# verify: test-bats
#
# NIMMT DER VORAB-REGEL IHR MUSTER: ein Vorab-Tag (`v1.0.0-RC`) geht danach wie ein
# stabiler Tag in den Vergleich, statt mit Exit 0 und "Vorab-Tag, Tap bleibt" zu enden.
# Rot faerbt der Fall, der die Meldung, den ausbleibenden docker-Aufruf und den
# ausbleibenden curl-Aufruf fuer drei Vorab-Tags liest.
set -euo pipefail
sed -i 's@^\*-\*)$@__nie__)@' harness/tools/tap-nachzug.sh
