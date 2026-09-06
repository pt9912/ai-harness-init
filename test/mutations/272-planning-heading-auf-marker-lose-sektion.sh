#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: heading zeigt auf den Abschnitt 'Offene Wellen', nicht auf den Modul-Default
#
# Setzt `heading` auf "## Meilensteine" — ein Abschnitt, den die Roadmap fuehrt und der den
# Ruhe-Marker nie traegt. `docs-check` faellt darauf NICHT rot (die Ueberschrift existiert, und der
# Block ohne Marker bleibt konsistent mit dem besetzten `in-progress/` dieses Baums) — 0 Befund(e),
# Exit 0. Dieser Waechter haelt die Kopplung an den Abschnitt, ueber dem die Invariante wirklich
# driften kann, unabhaengig davon, ob die Ueberschrift selbst existiert.
set -euo pipefail
sed -i 's/^  heading: "## Offene Wellen"$/  heading: "## Meilensteine"/' .d-check.yml
