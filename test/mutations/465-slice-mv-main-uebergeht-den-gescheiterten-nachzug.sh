#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb
# verify: test-go
#
# NIMMT main() DIE AUSWERTUNG DES STATUS VON rewrite_incoming_nach_baum: ein
# Status 2 (die Ersetzung ist gescheitert) bricht den Lauf nicht mehr ab, die
# Datei zaehlt als nicht zum Nachzug gehoerig, und der Lauf endet mit 0 und dem
# Erfolgssatz, obwohl der Nachzug nicht stattgefunden hat.
#
# test/slice-mv.bats sieht das nicht: seine Faelle rufen die Funktionen selbst,
# nie main() — und das gepinnte bats-Image fuehrt kein git. Der Go-Test faehrt
# main() als echten Prozess ueber ein Repo, in dem jeder `sed -E` scheitert.
#
# Der Anker steht genau einmal im Skript, als Bedingung des Abbruchs in main()
# (grep -c 'if \[ "[$]rc" -gt 1 \]; then' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~if \[ "[$]rc" -gt 1 \]; then~if false; then~' harness/tools/slice-mv.sh
