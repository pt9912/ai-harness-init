#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: main() ueberspringt NUR bei einem Beleg, der dem aktuellen Schluessel entspricht
#
# Nimmt der Uebersprung-Bedingung ihren DRITTEN Teil: den Gleichheits-Vergleich zwischen dem
# Inhalt der Beleg-Datei und dem aktuellen belief_key. Uebrig bleibt "kein MUTATE_FORCE UND
# eine Beleg-Datei liegt vor" — eine Beleg-Datei mit VOELLIG BELIEBIGEM Inhalt genuegt danach
# fuer den Uebersprung, unabhaengig davon, ob sie zum laufenden Baum passt. Genau das ist
# Bedingung 6 im Kopf ("NUR bei exaktem Schluessel-Treffer"), und ohne diesen Fall war sie
# unbewacht: kein anderer bats-Test startet main() mit einer VORLIEGENDEN, ABWEICHENDEN
# Beleg-Datei.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, wie test/mutations/162): der Vergleich
# `[ "$(cat "$BELIEF" 2>/dev/null)" = "$belief_key" ]` kommt in der Datei genau einmal vor.
set -euo pipefail
sed -i "s@ && \[ \"\$(cat \"\$BELIEF\" 2>/dev/null)\" = \"\$belief_key\" \]@@" harness/tools/mutate.sh
