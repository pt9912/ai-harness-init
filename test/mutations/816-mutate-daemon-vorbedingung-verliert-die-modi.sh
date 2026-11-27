#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: fehlt der Daemon fuer einen Daemon-Modus, bricht der Lauf als Umgebungs-Befund VOR der Isolationskopie
# verify: test-bats
#
# RAEUMT DIE MODI AUS DER DAEMON-VORBEDINGUNG: der Fall-Arm der Daemon-Klasse
# (`smoke | full-smoke` im Daemons-Zug) wird umgeschrieben — die zwei noch
# daemon-gebundenen Modi bootstrappen tmp-Repos mit Docker-Gates, und ihre
# Werkzeug-Abwesenheit ist ohne die Vorbedingung wieder an einem Test-Ausgang lesbar:
# Der Lauf faehrt die Isolationskopie an, der Gruen-Vorlauf bricht am Daemon, und die
# Meldung nennt die Ursache nicht mehr als Umgebungs-Befund (LH-QA-01).
#
# ANKER: die Fall-Arm-Form `smoke | full-smoke) daemons=` steht im mutate.sh genau
# einmal — beide Muster der Arm-Klassifikation in einem Arm; der Kopf nennt die zwei
# Modi in der Wort-Form `smoke · full-smoke` und trifft das Muster darum nicht. Die
# Ankerform ist auf den GANZEN Arm gerichtet: eine Verschiebung, die nur eines der
# zwei Muster umbenennt, verliert die halbe Vorbedingung und laesst die andere
# Modus-Klasse still gruen — die Anlage verschiebt darum beide.
#
# ERWARTETER ROT-GRUND: `driver: fehlt der Daemon fuer einen Daemon-Modus, bricht der
# Lauf als Umgebungs-Befund VOR der Isolationskopie` faellt an der Status- und der
# Meldungs-Assertion (Exit 1 statt 4, Ursache am Fall-Zug statt an der Vorbedingung).
set -euo pipefail
sed -i 's@smoke | full-smoke) daemons=@smoke-ohne-daemon | full-smoke-ohne-daemon) daemons=@' harness/tools/mutate.sh
