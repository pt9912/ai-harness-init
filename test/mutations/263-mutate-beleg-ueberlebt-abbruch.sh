#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: main() loescht einen bestehenden Beleg SOFORT, wenn der Lauf danach abbricht (kein Ueberleben)
#
# Nimmt main() die SOFORTIGE Entwertung des Beleg-Slots. Ohne sie steht ein bestehender
# Beleg unberuehrt weiter, bis `finalize_belief` als letzte Anweisung von main() ihn
# behandelt -- und JEDER der sechs `exit`-Pfade dazwischen (leeres Fall-Set,
# Fingerabdruck, unbekannter Modus, require_isolated, Gruen-Vorlauf, on_signal)
# hinterlaesst ihn dann faelschlich gueltig: ein erzwungener Lauf, der nach der
# Beleg-Pruefung rot abbricht, laesst den ALTEN Beleg stehen, und der naechste
# unerzwungene Aufruf meldet faelschlich "unveraendert", Exit 0.
#
# Anker ohne literales Dollar (SC2016, wie die uebrigen Faelle in diesem Verzeichnis):
# `  clear_belief` allein auf einer Zeile ist eindeutig der neue Aufruf in main(),
# `clear_belief()` (die Definition, zwei Zeilen davor mit Klammern) bleibt unberuehrt.
set -euo pipefail
sed -i '/^  clear_belief$/d' harness/tools/mutate.sh
