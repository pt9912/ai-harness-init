#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: pin: ein Bild ohne Digest endet mit Exit 2 vor docker
# verify: test-bats
#
# MACHT DIE PIN-PRUEFUNG WIRKUNGSLOS: ein Bild ohne Digest-Pin (`curlimages/curl:latest`)
# geht danach in den docker-Aufruf. Der Transport laeuft dann in einem Bild, das nicht
# gepinnt ist (LH-QA-02).
# Rot faerbt der Fall, der Exit 2, die Meldung und den ausbleibenden docker-Aufruf liest.
set -euo pipefail
sed -i 's@^\*) fehler "TAP_IMAGE@*) : "TAP_IMAGE@' harness/tools/tap-nachzug.sh
