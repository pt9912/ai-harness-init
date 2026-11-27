#!/usr/bin/env bash
# files: Makefile
# expect: rezept: shell-lint hält dieselbe Pfadliste wie der Image-Weg und schaltet bats-lint auf Host
# verify: test-bats
#
# Tauscht den Host-Schalter aus: der Pflicht-Weg `shell-lint` ruft bats-lint.sh
# ohne BATS_HOST=1 — das Skript verlangt dann die Image-Pins (BATS_IMAGE/
# SHELLCHECK_IMAGE) und der docker-lose Lauf endet an der ":"-Sperre
# ("BATS_IMAGE fehlt") statt am shellcheck-Urteil. Rot faerbt
# test/rezept-host.bats (die Schalter-Zeile im Rezept-Text).
set -euo pipefail
sed -i 's|BATS_HOST=1 bash harness/tools/bats-lint.sh|BATS_HOST=x bash harness/tools/bats-lint.sh|' Makefile
