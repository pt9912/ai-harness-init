#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: vorab-tag: die Regel des Skripts entscheidet dieselben Tags wie die Regel des publish-Jobs
# verify: test-bats
#
# LAESST DAS BUILD-METADATUM STEHEN: `v1.0.0+build-1` traegt danach ein `-` im Metadatum und
# gilt als Vorab-Tag, obwohl der publish-Job von release.yml es stabil entscheidet.
# Rot faerbt der Kopplungs-Fall, der Skript und Job gegen dieselbe Tag-Liste haelt.
set -euo pipefail
sed -i 's@^case "[$]{tag%%+\*}" in$@case "\x24{tag}" in@' harness/tools/tap-nachzug.sh
