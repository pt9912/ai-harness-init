#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: waves.mode ist many (Bijektion statt Singleton-Default)
#
# Setzt `mode: many` unter `waves:` auf den Modul-Default `one` zurueck — ein Singleton-Praedikat
# statt der Kennungs-Bijektion, die diese Faehigkeit fuer den Abschnitt "## Offene Wellen" haelt.
# Dieser Waechter haelt die Modus-Entscheidung ohne einen Docker-Lauf.
set -euo pipefail
sed -i 's/^\(    mode: \)many$/\1one/' .d-check.yml
