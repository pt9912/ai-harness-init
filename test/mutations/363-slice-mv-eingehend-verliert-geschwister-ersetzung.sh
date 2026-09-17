#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: eingehend praefixlos: jeder Link auf die bewegte Datei bekommt ../ZIEL/
# verify: test-bats
#
# NIMMT DER PRAEFIXLOSEN EINGEHEND-ERSETZUNG IHR sed. rewrite_incoming_bare_in_file()
# zaehlt die Links danach weiter, ersetzt aber keinen; main() ruft genau diese
# Funktion fuer die Geschwister im Ausgangsverzeichnis auf, und ein Link
# "](<datei>)" zeigt nach dem Wechsel weiter auf das Verzeichnis, das die Datei
# verlassen hat.
#
# Getroffen wird die Dogfood-Fassung, die `make slice-mv` in diesem Repo faehrt.
# Rot faerbt der Fall, der die Funktion ohne Repository ruft und den ganzen
# Dateiinhalt einer Probe liest; der Kopplungs-Fall wird daneben ebenfalls rot,
# weil die zwei Fassungen dann auseinanderlaufen.
#
# Der Anker `esc_base([)#])` steht genau einmal im Skript, im sed dieser Funktion;
# die Zaehl-Zeile davor traegt das Muster ohne Klammer-Gruppe.
set -euo pipefail
sed -i '/esc_base(\[)#\])/d' harness/tools/slice-mv.sh
