#!/usr/bin/env bash
# files: harness/tools/dcheck-fetch.sh
# expect: happy: die Kette Pin↔Index↔Manifest↔Blobs traegt
# verify: test-bats
#
# Entzaubert die Byte-Verifizierung der OCI-Kette im docker-losen d-check-Zugang
# (slice-binraire-ziehen-ohne-docker, ADR-0109/LH-QA-02): `[ "$ist" != "$2" ]`
# wird zu `[ -n "$ist" ]` — die Pruefung feuert dann an JEGLICHER geladenen
# Stelle (Index, Manifest, Blob) und misst nichts. ROT, vollstaendige Menge
# (Hand-Mutation an der realen Datei, gemessen): Tests 2 (happy — der Lauf
# bricht mit der Abweichungs-Meldung trotz gleicher Summen), 4 (Blob-Abweichung
# — statt der Meldung schlaegt das entzaerte tar) und 5 (Member-Zuordnung —
# derselbe fruehe Abbruch schlaegt die erwartete Meldung). GRUEN bleibt Test 3:
# sein erwarteter Fehlschlag-Typ (Exit 1 + Abweichungs-Meldung am Index) trifft
# unter der Mutation zufaellig denselben Wortlaut — der tragende Zahn ist der
# Happy-Fall; die Meldung allein misst ihn nicht.
set -euo pipefail
sed -i 's/\[ "$ist" != "$2" \]/[ -n "$ist" ]/' harness/tools/dcheck-fetch.sh
