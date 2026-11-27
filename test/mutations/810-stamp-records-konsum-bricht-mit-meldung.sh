#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: stamp-records: ein fehlendes Result-File bricht fail-closed und fasst den Fall-File-Bestand nicht an
# verify: test-bats
#
# FAEHRT DIE fehlt-Pruefung des Konsums zurueck (ADR-0107 Festlegung 3; LP 2): die
# Zeile `stamp_records_abbruch "Result-File fehlt: …"` liest als `:` — der Mutant
# bleibt parsbar, die if-Fassung bewertet `[ ! -f ]` weiter und faellt durch, der
# Konsum liest das fehlende Result-File dann OHNE die `stamp-records: ABBRUCH —
# Result-File fehlt`-Meldung (der `Result-File ist leer`-Abbruch des nachgelagerten
# Checks tritt an ihre Stelle) und der Waechter
# `stamp-records: ein fehlendes Result-File bricht fail-closed...` faerbt an der
# Meldung-Zusage rot (Leer-File tritt durch denselben Mutat NICHT: seine Zeile
# steht unverändert). Anlage misst den sed-Anker gegen den Quell-Bestand (MR-071:
# die Meldung-Zeile steht genau einmal); Anker am Commit (MR-090).
set -euo pipefail
sed -i 's/\(  *\)stamp_records_abbruch "Result-File fehlt:.*/\1:/' harness/tools/mutate.sh
