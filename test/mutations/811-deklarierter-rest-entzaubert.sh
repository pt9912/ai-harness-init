#!/usr/bin/env bash
# files: harness/tools/gates-keys.sh
# expect: keys: der Walk liegt ganz in der Tafel-Vereinigung oder einer deklarierten Rest-Klasse; ein undeklarierter Neuzugang faellt auf
# verify: test-bats
#
# FAEHRT DIE Deklaration des Zuordnungs-REST (ADR-0108 Abwaegung E,
# Deklarations-Form; Plan-Fortschreibung slice-stamp-records-konsum-v1 §3) zurück:
# die continue-Zeile der Rest-Lesung fällt, `rest` nennt die 14 deklarierten
# Klassen-Dateien wieder (Exit 1), und der Wächter
# `keys: der Walk liegt ganz in der Tafel-Vereinigung oder einer deklarierten
# Rest-Klasse; ein undeklarierter Neuzugang faellt auf` färbt über dem realem
# Wurzel-Bestand rot. Anlage messen gegen den Bestand (MR-071: `ist_rest_zeile
# "$f" && continue` steht genau einmal, die Funktions-Zeilen weiter oben bleiben);
# Anker am Commit (MR-090).
set -euo pipefail
sed -i '/^      ist_rest_zeile "\$f" && continue$/d' harness/tools/gates-keys.sh
