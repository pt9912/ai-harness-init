#!/usr/bin/env bash
# files: harness/tools/pre-commit-amend-guard.sh
# expect: decide: zwei fremde Pfade, nur einer bestaetigt -> exit 1 (fail-closed)
# verify: test-bats
#
# MACHT AUS DER TEIL-BESTAETIGUNG EINEN BLANKOSCHECK: die Bedingung
# `[ -z "$missing" ]` wird zu `true` — decide() haelt dann jeden Amend an,
# sobald AMEND_EXPECTED_PATHS irgendetwas enthaelt, ohne zu pruefen, ob damit
# WIRKLICH jeder fremde Pfad genannt ist.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: Aufrufer ist .githooks/pre-commit ueber
# den vollen Lauf; die bats-Stufe faehrt `decide()` ueber `--decide`, denselben
# Einstieg, den der volle Lauf am Ende aufruft (kein Nachbau der Verdrahtung).
#
# WARUM die bats-Stufe die schmalste ausreichende ist: geprueft wird die REINE
# Entscheidung mit Fixture-Pfaden — bash und coreutils, kein Docker, kein `git`
# (das gepinnte bats-Image fuehrt keines, s. Skriptkopf Abschnitt ENTSCHEIDUNG).
set -euo pipefail
sed -i "s/if \[ -z \"\$missing\" \]; then/if true; then/" harness/tools/pre-commit-amend-guard.sh
