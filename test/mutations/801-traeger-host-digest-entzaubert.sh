#!/usr/bin/env bash
# files: harness/tools/traeger-fetch-host.sh
# expect: happy im Pin-Modus: mit exportiertem Pin verifiziert
# verify: test-bats
#
# Entzaubert die Byte-Verifizierung am docker-losen Träger-Fetch am Host
# (Pflicht-Weg je ADR-0109, Pin-Kopplung je ADR-0059): `[ "$ist" != "$sha" ]`
# wird zu `[ -n "$ist" ]` — ein gegen den Pin (oder den SHA256SUMS-Eintrag)
# abweichendes Asset wird abgelegt, statt fail-closed zu brechen ohne Ablage.
# Rot faerbt test/traeger-fetch-host.bats, Test "happy im Pin-Modus: mit
# exportiertem Pin verifiziert der Lauf gegen den Makefile-Pin und legt den
# Traeger ab, lauffaehig" (dieselbe Bedingung traegt den Manifest-Modus-Fall —
# beide faellen unter der Mutation). Rot gesehene Gegenprobe: Hand-Mutation an
# der realen Datei, Test 1 und 2 fielen.
set -euo pipefail
sed -i 's/\[ "$ist" != "$sha" \]/[ -n "$ist" ]/' harness/tools/traeger-fetch-host.sh
