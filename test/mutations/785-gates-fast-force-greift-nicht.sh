#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: fastpfad: GATES_FORCE=1 ueber gedecktem Satz -> voller Lauf
# verify: test-bats
#
# SCHALTET DEN AUSSCHALTER AB: der Wert-Vergleich des FORCE-Schalters in der
# Klassifikation (`entscheide`, `if [ "$force" = "1" ]; then return 1; fi`) wird auf
# einen Vergleich geschoben, den kein Wert erfuellt (literal `..force.` gegen
# `..0.`) — `GATES_FORCE=1` zwingt dann NICHT mehr den vollen Lauf ueber dem
# gedeckten je-Check-Satz. Der benannte Rest aus ADR-0108 Festlegung 4 (Docker-Cache-
# Zustand, Host-Werkzeuge) waere damit nicht mehr behebbar: seine Zusage haengt an
# diesem Vergleich (Festlegung 3), und ihr Zahn faerbt den Boundary-Test rot.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: dieselbe wie im Fall 784 — Aufrufer ist das
# Make-Target `gates`; die bats-Stufe faehrt `--entscheide` mit dem FORCE-Wert,
# denselben Einstieg wie der Lauf.
#
# ANKER: die Vergleichsform `[ ..force. = .1. ]` (Wildcard-Fassung von
# `[ "$force" = "1" ]`, Wert-Seite `.1.` = drei Zeichen) trifft im Bestand genau die
# zwei Vergleichs-Zeilen des Schalters (die in `entscheide` und die auf dem Lauf-Pfad);
# literale `$` im Muster waere SC2016 (die Fall-Skripte dieses Verzeichnisses verankern
# ohne literales Dollar), und die Wert-Seite einer `"1"` ist drei, nicht vier Zeichen.
#
# ERWARTETER ROT-GRUND: `fastpfad: GATES_FORCE=1 ueber gedecktem Satz -> voller
# Lauf` wird rot — unter der Mutation vergleicht der Schalter kein `1` mehr und
# `GATES_FORCE=1` SKIPpt fortan ueber dem gedeckten Satz (Exit 0 statt 1) —
# `test/gates-fastpfad.bats:116`. Die ungedeckten Zustaende urteilen weiter
# fail-closed. GRENZE: der andere Rand des Schalters faellt hier NICHT mit — der
# Vergleich trifft nur die zwei `force = "1"`-Zeilen, und
# `fastpfad: GATES_FORCE=0 sagt nichts (gedeckter Satz bleibt SKIP)`
# (`test/gates-fastpfad.bats:122`) bleibt darueber gebunden, nicht durch diesen Fall.
set -euo pipefail
sed -i 's@\[ ..force. = .1. \]@[ ..force. = ..0. ]@' harness/tools/gates-fast.sh
