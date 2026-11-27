#!/usr/bin/env bash
# files: harness/tools/environment-check.sh
# expect: environment-check: exakte Abweichung färbt Umgebungs-Befund mit Werkzeug, Soll und Ist
# verify: test-bats
#
# Zersaegt die exakte Soll-Paarung der Pruefform exakt: `[ "$ist" = "$anzeige" ]`
# wird zu `[ -n "$ist" ]` — jede lesende Version-traegt-Zeile gilt dann als gruen.
# Rot faerbt test/environment-check.bats, Test "exakte Abweichung färbt
# Umgebungs-Befund mit Werkzeug, Soll und Ist": der Stub-Aufruf dort traegt 1.99.0
# gegen Soll 1.27.3 und erwartet exit 1 (reale Quelle des Falls: der Fixtures-Stub
# und der Skript-Vergleich; das reale Rot der Umgebungs-Zusage am Host ist am
# Skriptkopf protokolliert — Skriptkopf §Protokoll der Break-Tests).
set -euo pipefail
sed -i "s/elif \[ \"\\\$ist\" = \"\\\$anzeige\" \]; then/elif [ -n \"\$ist\" ]; then/" harness/tools/environment-check.sh
