#!/usr/bin/env bash
# record-gates — Nachweis schreiben, dass `make gates` den aktuellen
# Arbeitsbaum-Zustand abgedeckt hat. Der Stop-Hook vergleicht denselben Hash.
# Adoptiert aus d-check/b-cad (harness/conventions.md MR-002).
#
# DIESES SKRIPT LIEST KEIN ERGEBNIS und kann es nicht: `make` gibt dem Rezept keinen
# Ergebnis-Kanal. Dass der Nachweis nicht über einem roten Check entsteht, trägt allein
# die Ordnungskante im Makefile (`record-gates: <checks>`) — sie verhindert, dass make
# dieses Ziel nach einem gefallenen Check noch baut, auch unter `-k`. Wächter über der
# Kante: test/gate-nachweis-kante.bats.
#
# GRENZE, drei Wege: `make -i` (--ignore-errors) lässt das Rezept nach einem gefallenen
# Check laufen; ein Aufruf des Skripts an make vorbei (`bash harness/tools/record-gates.sh`)
# kennt gar keinen Check; und unter `make -j` sagt die Kante nur, wovon das Ziel abhängt,
# nicht, in welcher Reihenfolge die Checks liefen. `make record-gates` gehört NICHT dazu —
# die Kante zieht dort dieselben Checks mit wie unter `make gates`.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mkdir -p .harness/state
bash harness/tools/working-tree-hash.sh > .harness/state/gates-passed.diffsha
