#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein voller Lauf mit Befund nennt den Pruefgegenstand-Schluessel
#
# Streicht den Aufruf von report_key aus dem Zweig des vollen Laufs in main(). Ein voller Lauf,
# der mit Befund endet, nennt dann keinen Pruefgegenstand-Schluessel, und die Vereinigung zweier
# Laeufe (harness/sensors/mutate.md, „Zwei Laeufe, eine Aussage") hat fuer ihren Hauptlauf
# keine Zeile, an der sie den Baum erkennt.
#
# Anker: der Aufruf `    report_key "$belief_key"` (vier Leerzeichen) steht einmal, in main();
# report_partial ruft report_key mit `"$key"` und zwei Leerzeichen Einrueckung.
set -euo pipefail
sed -i '/^    report_key "[$]belief_key"$/d' harness/tools/mutate.sh
