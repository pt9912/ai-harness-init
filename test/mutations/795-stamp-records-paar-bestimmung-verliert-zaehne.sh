#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: stamp: die doppelte (fall, run, attempt)-Bestimmung gegen den Bestand bricht fail-closed mit Meldung und der Bestand bleibt unveraendert
#
# ENTWERTET die Paar-Bestimmung des Result-Konsums (ADR-0107 Festlegung 3): der
# stamp_abbruch-Aufruf an der Paar-Prüfung wird zum No-op, ein Konsum über ein
# bereits gestempeltes (fall, run, attempt)-Paar hängt die Zeile still ein zweites
# Mal an und läuft grün — die doppelte Bestimmung, die der Bestand gerade ausschaltet
# soll ("das Paar steht bereits im Fall-File"), ist entwaffnet. Färbt
# test/stamp-records-mechanik.bats rot — den Fall "die doppelte (fall, run,
# attempt)-Bestimmung gegen den Bestand bricht fail-closed mit Meldung und der
# Bestand bleibt unveraendert" (Exit 0 statt 1, doppelter Anhang); die übrigen
# Grenzen (derselbe Fall zweimal im Result-File — ein anderer Meldungs-Anker —,
# unbekannte/mehrdeutige Kennung, Result-File-Formen) treffen ihre Fehlerstelle
# nicht und bleiben grün: das rot aus dem richtigen Grund.
#
# Anlage je MR-071 gegen den heutigen Quell-Bestand: der Anker zitiert die
# stamp_abbruch-Zeile der Paar-Prüfung, wie sie im Commit dieses Falls liegt
# (`grep -c 'stamp_abbruch "doppelte Bestimmung: Paar' harness/tools/mutate.sh` → 1).
# Anker am Commit je MR-090: die Fall-Anlage greift in den Gates
# (`make mutate-greift` löst die '# files:'-Angabe gegen den Bestand des Commits auf).
set -euo pipefail
sed -i 's@stamp_abbruch "doppelte Bestimmung: Paar@:       "doppelte Bestimmung: Paar@' harness/tools/mutate.sh
