#!/usr/bin/env bash
# files: harness/tools/environment-inventory.txt
# expect: pinsync: das Inventar-Soll der Zeile go driftet byte-genau von der GO_VERSION-Stelle des Makefile weg — die Mischform-Paarung faerbt docs-check mit pinsync-mismatch rot
# verify: test-bats
#
# Verfaelscht den abgeleiteten Soll-Wert der go-Zeile (1.27.3 -> 9.9.9) auf GENAU EINER
# der beiden Quellen: der Pin legt fest (Makefile GO_VERSION), das Inventar traegt die
# byte-genau gepaarte Kopie, `make environment-check` prueft den Host gegen sie — eine
# Drift zwischen den Stellen faerbt das Doku-Gate rot, bevor der Check ein altes Soll
# still weitertraegt (Grund-Code `pinsync-mismatch`; Beleg-Typ:
# harness/sensors/docs-check.md §Grenze, Modul pinsync). Der Config-Zahn der Paarung
# (Quellen-Zeile weg) ist Fall 795; der Laufzeit-Zahn am Skript ist Fall 797.
set -euo pipefail
sed -i 's/abgeleitet:1\.27\.3/abgeleitet:9.9.9/' harness/tools/environment-inventory.txt
