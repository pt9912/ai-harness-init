#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Umgebungs-Befund bricht vor Beleg-Entwertung und Isolationskopie ab; die Diagnose nennt Werkzeug · Soll · Ist
# verify: test-bats
#
# LOEST DIE EXIT-TRENNUNG: beide Umgebungs-Abbruecke im main-Einstieg (Inventar-Check
# und Daemon-Vorbedingung) enden mit der eigenstaendigen Exit-Klasse 4 — die Klasse ist
# von den Test-Ausgaengen getrennt, die den Lauf ueber die Befund-Summe mit Exit 1
# beenden. Verschiebt man beide auf Exit 1, urteilt der Umgebungs-Abbruch wie ein
# Befund-Lauf: die Diagnose (Werkzeug · Soll · Ist) bleibt zwar stehen, die Klasse ist
# aber nicht mehr an der Ausgangs-Zeile lesbar — genau die Vermischung, gegen die die
# Vorbedingung eingefuehrt wurde (LH-QA-01).
#
# ANKER: `exit 4` steht im mutate.sh in genau diesen zwei Umgebungs-Branches; kein
# anderer Ausgang des Treibers endet mit 4 (Sperren und Befunde enden mit 1, Signale
# mit 130). Im Kopf-Kommentar steht die Klasse gross (Exit 4) und trifft das
# Kleinbuchstaben-Muster darum nicht.
#
# ERWARTETER ROT-GRUND: `driver: ein Umgebungs-Befund bricht vor Beleg-Entwertung und
# Isolationskopie ab; die Diagnose nennt Werkzeug · Soll · Ist` faellt an der
# Status-Assertion (Exit 1 statt 4); dieselbe Verschiebung trifft den
# Daemon-Befund-Test daneben.
set -euo pipefail
sed -i 's@exit 4@exit 1@' harness/tools/mutate.sh
