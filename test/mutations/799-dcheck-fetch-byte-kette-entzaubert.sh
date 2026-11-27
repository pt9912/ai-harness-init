#!/usr/bin/env bash
# files: harness/tools/dcheck-fetch.sh
# expect: happy: die Kette Pin↔Index↔Manifest↔Blobs traegt
# verify: test-bats
#
# Entzaubert die Byte-Verifizierung der OCI-Kette im docker-losen d-check-Zugang
# (slice-binraire-ziehen-ohne-docker, ADR-0109/LH-QA-02): `[ "$ist" != "$2" ]`
# wird zu `[ -n "$ist" ]` — jede geladene Stelle (Index, Manifest, Blob) gilt dann
# als verifiziert; ein abweichender Blob faerbt keinen Lauf rot. Rot faerbt
# test/dcheck-fetch.bats, Test "happy: die Kette Pin↔Index↔Manifest↔Blobs traegt,
# das Member wird gelegt und startet, docker-los" (der Happy-Fall bricht dann mit
# der Abweichungs-Meldung trotz gleicher Summen — der Zahn misst die Bedingung,
# nicht die Meldung); rot gesehene Gegenprobe: Hand-Mutation an der realen Datei,
# Test 2 und 4 fielen. Grenze des Winkels: test 3 bleibt unter Zerstoerung des
# Checks gruen (dasselbe Verhalten mit entzaunter Bedingung ist dort der
# erwartete Fehlschlag-Typ) — der tragende Zahn ist der Happy-Fall.
set -euo pipefail
sed -i 's/\[ "$ist" != "$2" \]/[ -n "$ist" ]/' harness/tools/dcheck-fetch.sh
