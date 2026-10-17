#!/usr/bin/env bash
# files: harness/tools/digest-freshness.sh
# expect: compare ungleich -> exit 1, nennt Tag, beide Digests und die Stelle
#
# Der Vergleicher meldet "aktuell", sobald die Aufloesung nur nicht leer ist: ein Digest, der
# nicht zum Tag gehoert, faerbte den Nacht-Lauf nicht mehr (LH-QA-02). Rot wird der Fall mit
# zwei verschiedenen Digests in test/digest-freshness.bats.
set -euo pipefail
sed -i 's/if \[ "[$]actual" = "[$]pinned" \]; then/if [ 1 -eq 1 ]; then/' harness/tools/digest-freshness.sh
