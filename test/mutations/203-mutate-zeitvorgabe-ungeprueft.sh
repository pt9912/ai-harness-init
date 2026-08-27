#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: eine unsinnige MUTATE_STALL_SECONDS-Vorgabe BRICHT AB, statt die Schranke abzuschalten
#
# Nimmt der Zeit-Vorgabe ihre fail-closed-Pruefung. Eine unsinnige Vorgabe schaltet danach
# LAUTLOS die Zusage von DoD (1) ab: gemessen ergab `MUTATE_STALL_SECONDS=abc` fuenfzehn
# Arithmetik-Fehler und NULL Zeitschranken-Befunde — der Lauf lief weiter, als gaebe es
# keine Schranke.
# Getroffen ist nur die ZEIT-Vorgabe; die Worker-Zahl teilt sich dieselbe Funktion und
# bleibt geprueft, damit der Fall genau eine Zusage adressiert.
set -euo pipefail
sed -i "s|^  if ! require_positive_int \"\$STALL_SECONDS\"; then|  if false; then|" harness/tools/mutate.sh
