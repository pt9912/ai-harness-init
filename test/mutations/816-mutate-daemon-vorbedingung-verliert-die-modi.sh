#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: fehlt der Daemon fuer einen Daemon-Modus, bricht der Lauf als Umgebungs-Befund VOR der Isolationskopie
# verify: test-bats
#
# RAEUMT DIE DAEMON-KLASSE AUS DER VORBEDINGUNG: der Fall-Arm der Daemonklasse
# (`full-smoke` — seit slice-smoke-und-full-smoke-ohne-docker der EINZIGE Traeger der
# Sperre: der smoke-Modus faehrt host-native und ist aus der Liste entlassen) wird
# umgeschrieben — der daemon-gebundene Modus bootstrapt tmp-Repos an Docker-bundenen
# Stufen, und seine Werkzeug-Abwesenheit ist ohne die Vorbedingung wieder an einem
# Test-Ausgang lesbar: Der Lauf faehrt die Isolationskopie an, der Gruen-Vorlauf
# bricht am Daemon, und die Meldung nennt die Ursache nicht mehr als Umgebungs-Befund
# (LH-QA-01).
#
# ANKER: die Fall-Arm-Form `full-smoke) daemons=` steht im mutate.sh genau einmal —
# seit der smoke-Entlassung traegt der Arm EINEN Modus; der Kopf nennt den Modus in
# der Wort-Form `full-smoke` und trifft das Muster darum nicht. Die Ankerform ist auf
# den GANZEN Arm gerichtet: eine Verschiebung, die den Modus umbenennt, verliert die
# Daemon-Klasse und laesst sie still gruen.
#
# ERWARTETER ROT-GRUND: `driver: fehlt der Daemon fuer einen Daemon-Modus, bricht der
# Lauf als Umgebungs-Befund VOR der Isolationskopie` faellt an der Status- und der
# Meldungs-Assertion (Exit 1 statt 4, Ursache am Fall-Zug statt an der Vorbedingung).
set -euo pipefail
sed -i 's@full-smoke) daemons=@full-smoke-ohne-daemon) daemons=@' harness/tools/mutate.sh
