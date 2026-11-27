#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: fastpfad: GATES_FORCE=1 ueber gedecktem Satz -> voller Lauf
# verify: test-bats
#
# SCHALTET DEN AUSSCHALTER AB: der Wert-Vergleich des FORCE-Schalters in der
# Klassifikation (`entscheide`, `if [ "$force" = "1" ]; then return 1; fi`) wird auf
# `0` geschoben — `GATES_FORCE=1` zwingt dann NICHT mehr den vollen Lauf ueber dem
# gedeckten je-Check-Satz. Der benannte Rest aus ADR-0108 Festlegung 4 (Docker-Cache-
# Zustand, Host-Werkzeuge) waere damit nicht mehr behebbar: seine Zusage haengt an
# diesem Vergleich (Festlegung 3), und ihr Zahn faerbt den Boundary-Test rot.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: dieselbe wie im Fall 784 — Aufrufer ist das
# Make-Target `gates`; die bats-Stufe faehrt `--entscheide` mit dem FORCE-Wert,
# denselben Einstieg wie der Lauf.
#
# ERWARTETER ROT-GRUND: `fastpfad: GATES_FORCE=1 ueber gedecktem Satz -> voller
# Lauf` wird rot (`GATES_FORCE=1` SKIPpt fortan ueber dem gedeckten Satz), und mit
# ihm `fastpfad: GATES_FORCE=0 sagt nichts` (Exit 0 statt 1) — die zwei
# Boundary-Klassen des Schalters fallen; die ungedeckten Zustaende urteilen weiter
# fail-closed.
set -euo pipefail
sed -i 's@\[ ..force... = ...1.. \]@[ "$force" = "0" ]@' harness/tools/gates-fast.sh
