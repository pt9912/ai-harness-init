#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: stamp-records: ein fehlendes Result-File bricht fail-closed und fasst den Fall-File-Bestand nicht an
# verify: test-bats
#
# FAEHRT DIE fail-closed-PRUEFUNG des Konsums zurück (ADR-0107 Festlegung 3; LP 2):
# die Vorlauf-Checks `Result-File fehlt`/`ist leer` fallen — der Konsum liest ein
# fehlendes oder leeres Result-File dann ohne die `stamp-records: ABBRUCH`-Meldung
# (der bash-Lesefehler tritt an ihre Stelle) und der Wächter am
# test/stamp-records-mechanik.bats färbt an der Meldung-Zusage rot. Bestand:
# `stamp_records_abbruch "Result-File fehlt: ` steht genau einmal (Anlage messen,
# MR-071); Anker am Commit (MR-090).
set -euo pipefail
sed -i '/^  if \[ ! -f "\$resultfile" \]; then$/,/^  fi$/d' harness/tools/mutate.sh
