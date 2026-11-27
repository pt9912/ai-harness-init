#!/usr/bin/env bash
# files: harness/tools/gates-keys.sh
# expect: keys: der Walk liegt ganz in der Tafel-Vereinigung oder einer deklarierten Rest-Klasse; ein undeklarierter Neuzugang faellt auf
# verify: test-bats
#
# FAEHRT DIE Deklaration des Zuordnungs-RESTs zurueck (ADR-0108 Abwaegung E,
# Deklarations-Form; Plan-Fortschreibung slice-stamp-records-konsum-v1 §3): die
# Lesung der MENGE_REST-Klassen faellt, `rest` nennt die deklarierten Klassen-Dateien
# wieder (Liste und Exit 1), und der Waechter `keys: der Walk liegt ganz in der
# Tafel-Vereinigung oder einer deklarierten Rest-Klasse...` faerbt ueber dem realen
# Wurzel-Bestand rot. Anlage misst den sed-Anker gegen den Quell-Bestand (MR-071:
# die continue-Zeile steht genau einmal); Anker am Commit (MR-090).
set -euo pipefail
sed -i "/^      ist_rest_zeile \"\$f\" && continue\$/d" harness/tools/gates-keys.sh
