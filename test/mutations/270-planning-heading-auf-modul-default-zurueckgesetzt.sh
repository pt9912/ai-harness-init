#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: heading zeigt auf den Abschnitt 'Offene Wellen', nicht auf den Modul-Default
#
# Setzt `heading` auf den Modul-Default "## Aktuelle Welle" — eine Ueberschrift, die
# docs/plan/planning/in-progress/roadmap.md nicht fuehrt. `docs-check` selbst faellt darauf bereits
# fail-closed (planning-drift, kanonische Ueberschrift fehlt); dieser Waechter haelt dieselbe
# Kopplung ohne einen Docker-Lauf.
set -euo pipefail
sed -i 's/^  heading: "## Offene Wellen"$/  heading: "## Aktuelle Welle"/' .d-check.yml
