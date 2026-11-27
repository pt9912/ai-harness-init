#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: die Umgebungs-Vorbedingung faehrt VOR Beleg-Entwertung und Isolationskopie
# verify: test-bats
#
# FAENGT DIE UMGEBUNGS-VORBEDINGUNG AB: der Aufruf des Inventar-Checks im main-Einstieg
# (`make --no-print-directory environment-check`, Umgebungs-Befund-Klasse Exit 4, der
# Abbruch vor Beleg-Lesung, Entwertung und Isolationskopie) wird auf `make ci-lint`
# verschoben — der Lauf fährt danach einen anderen gruenen make-Zug an derselben Stelle
# und ordnet die Umgebungs-Befund-Klasse keinem Lauf mehr zu, der sie trägt. Der
# Treiber fährt host-native Rezepte (ADR-0109); fehlt die Vorbedingung, bricht sein
# Gruen-Vorlauf an der Werkzeug-Umgebung, ohne sie als Umgebungs-Befund zu melden —
# genau die Vermischung von Werkzeug-Abwesenheit und Test-Ausgang (LH-QA-01).
#
# ANKER: die Byte-Form `make --no-print-directory environment-check` steht im
# mutate.sh genau einmal (der Aufruf im main-Einstieg); die Kopf-Kommentierung nennt
# den Ziel-Namen zweizeilig und trifft das Muster darum nicht.
#
# ERWARTETER ROT-GRUND: `driver: die Umgebungs-Vorbedingung faehrt VOR
# Beleg-Entwertung und Isolationskopie` faellt — die make-Protokoll-Assertion liest
# `ci-lint` als ersten Zug statt des Inventar-Checks.
set -euo pipefail
sed -i 's@make --no-print-directory environment-check@make --no-print-directory ci-lint@' harness/tools/mutate.sh
