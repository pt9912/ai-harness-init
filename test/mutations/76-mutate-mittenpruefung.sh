#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: run_case meldet einen HOST-Treffer
#
# Dreht die Mitten-im-Lauf-Pruefung um: aus "hat sich geaendert" wird "ist gleich".
# Der Treiber meldete dann einen Isolations-Bruch NICHT mehr — und genau diese Pruefung
# traegt die Kern-Zusage des Slice ("der Host-Baum wird nie veraendert"). Sie war bis
# hierher der einzige unbewachte Waechter des Slice; die Begruendung "als Mutations-Fall
# nicht darstellbar" trug nicht, weil beide Zweige VOR jedem make-Aufruf zurueckkehren
# (Review-Runde 2 F-1, Verifier R2-1).
#
# Anker: die Vergleichszeile in run_case, ueber den fall-lokalen Namen eindeutig
# (`case_now`) und dollar-frei gehalten (SC2016).
set -euo pipefail
sed -i 's/case_now" != "/case_now" = "/' harness/tools/mutate.sh
