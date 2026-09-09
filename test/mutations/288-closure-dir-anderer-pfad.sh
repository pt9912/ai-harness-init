#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure.dir zeigt auf docs/plan/planning/done
#
# Setzt `dir` unter `closure:` auf einen anderen, real existierenden Pfad
# (`docs/plan/planning/open` statt `docs/plan/planning/done`) — der Aktivierungs-Schalter bleibt
# gesetzt (Fall 285 deckt die leere Form bereits), aber er zeigt am geteilten Durchsetzungspunkt
# auf den falschen Bestand: `docs-check` prueft dann offene statt abgeschlossene Pakete und
# faerbt darauf 45 `closure-note-thin`-Befunde (EXIT 1) — der falsche Bestand wird gemeldet, nur
# unter der falschen Diagnose. Dieser Waechter haelt die Wert-Kopplung ohne einen Docker-Lauf.
set -euo pipefail
sed -i 's#^    dir: docs/plan/planning/done$#    dir: docs/plan/planning/open#' .d-check.yml
