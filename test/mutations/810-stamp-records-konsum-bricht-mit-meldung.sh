#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: stamp-records: ein fehlendes Result-File bricht fail-closed und fasst den Fall-File-Bestand nicht an
# verify: test-bats
#
# FAEHRT DIE fail-closed-PRUEFUNG des Konsums zurueck (ADR-0107 Festlegung 3; LP 2):
# die Abbruch-Zeilen der beiden Vorlauf-Checks `Result-File fehlt`/`ist leer` fallen —
# der Konsum liest ein fehlendes oder leeres Result-File dann ohne die
# `stamp-records: ABBRUCH`-Meldung (der Lesefehler des bash-Redirects bzw. der
# `gepruefter Commit:`-Abbruch treten an ihre Stelle) und der Waechter
# `stamp-records: ein fehlendes Result-File bricht fail-closed...` faerbt an der
# Meldung-Zusage rot. Anlage misst den sed-Anker gegen den Quell-Bestand (MR-071:
# die Meldung-Zeile steht genau einmal); Anker am Commit (MR-090).
set -euo pipefail
sed -i '/stamp_records_abbruch "Result-File fehlt:/d' harness/tools/mutate.sh
