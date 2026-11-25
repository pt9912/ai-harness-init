#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: fastpfad: GATES_FORCE=1 ueber gedecktem Paar -> voller Lauf
# verify: test-bats
#
# SCHALTET DEN AUSSCHALTER AB: der Wert-Vergleich von GATES_FORCE wird von `1` auf
# `0` geschoben — `GATES_FORCE=1` zwingt dann NICHT mehr den vollen Lauf ueber einem
# gedeckten Paar. Der benannte Rest aus ADR-0099 Festlegung 2 (Docker-Cache-Zustand,
# Host-Werkzeuge) waere damit nicht mehr behebbar: seine Zusage haengt an diesem
# Verglsystem (Festlegung 3), und ihr Zahn faerbt den Boundary-Test rot.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: dieselbe wie im Fall 784 — Aufrufer ist das
# Make-Target `gates`; die bats-Stufe faehrt `entscheide()` ueber `--entscheide`,
# denselben Einstieg wie der volle Lauf.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: siehe Fall 784 — bash und
# coreutils, kein Docker, kein `git`.
#
# ERWARTETER ROT-GRUND: `fastpfad: GATES_FORCE=1 ueber gedecktem Paar -> voller Lauf`
# wird rot (`GATES_FORCE=1` SKIPpt fortan ueber gedecktem Paar), und mit ihm
# `fastpfad: GATES_FORCE=0 sagt nichts` (Exit 0 statt 1) — die zwei Boundary-Klassen
# des Schalters fallen; die ungedeckten Paare urteilen weiter fail-closed.
set -euo pipefail
sed -i "s@\[ \"\$force\" = \"1\" \] && return 1@[ \"\$force\" = \"0\" ] \&\& return 1@" harness/tools/gates-fast.sh
