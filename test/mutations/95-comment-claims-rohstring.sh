#!/usr/bin/env bash
# files: harness/tools/comment-claims.sh
# expect: Roh-String-Literal ist ausgenommen
#
# Nimmt die Roh-String-Ausnahme weg: der Scanner liest danach auch EMITTIERTEN Inhalt
# (Go-`…`-Literale) als eigenen Kommentar. Der Gate roetet dann Adopter-Artefakte, die
# gar keine Zusage dieses Repos sind — ein Gate mit falschem Pruefbereich. Der bats-Fall
# "Roh-String-Literal ist ausgenommen" faellt dadurch.
set -euo pipefail
sed -i 's/if (was_raw || raw) { flush_block(); next }/if (0) { flush_block(); next }/' harness/tools/comment-claims.sh
