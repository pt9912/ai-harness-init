#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-hook.sh
# expect: TestCommitMsgTraeger_NenntSeineZweiGrenzen
# verify: test-go
#
# NIMMT DEM TRAEGER DIE UMGEHUNGS-ZEILE: der Hook prueft weiter wie zuvor, aber sein
# Kopf nennt `git commit --no-verify` nicht mehr.
#
# Die zweite Grenze derselben Trägerschaft ist die Aktivierung; die erste ist die
# Umgehung, die `git` selbst anbietet. Bleibt sie ungenannt, liest der naechste Lauf
# den Hook als Zaun statt als Stolperdraht (ADR-0004) und schliesst aus einem
# ungeprueften Klon auf einen geprueften.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Kopf des
# emittierten Traegers. Der Fall beruehrt kein Urteil — die Fahrt des Hooks faehrt
# test/commit-msg-emission.bats, den Aufruf durch git harness/tools/full-smoke.sh.
set -euo pipefail
sed -i '/--no-verify/d' internal/emit/templates/enforce/commit-msg-hook.sh
