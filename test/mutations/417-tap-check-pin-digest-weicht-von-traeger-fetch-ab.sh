#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: pin-kopplung: der Digest des Skripts ist der von traeger-fetch.sh
# verify: test-bats
#
# VERAENDERT EIN ZEICHEN DES DIGESTS in der Vorgabe des Skripts. Beide Skripte tragen
# danach verschiedene Transport-Bilder.
# Rot faerbt der Kopplungs-Fall, der beide Vorgaben liest und vergleicht.
set -euo pipefail
sed -i 's|curl@sha256:463eaf6072|curl@sha256:463eaf6073|' harness/tools/tap-nachzug.sh
