#!/usr/bin/env bash
# files: harness/tools/digest-freshness.sh
# expect: Hauptschleife, ein Digest weicht ab -> exit 1
#
# Die Hauptschleife merkt sich einen Befund (Exit 1 des Vergleichers) nicht mehr: ein Digest,
# der nicht zum Tag gehoert, endete mit Exit 0 und faerbte den Nacht-Lauf nicht (LH-QA-02).
# Rot wird der Schleifen-Fall mit PATH-Stub `docker` in test/digest-freshness.bats, der gegen
# die realen Pin-Dateien liest.
set -euo pipefail
sed -i 's/^    1) befund=1 ;;/    1) : ;;/' harness/tools/digest-freshness.sh
