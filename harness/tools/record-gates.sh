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
# GRENZE — die Wege, die den Nachweis über rotem Stand entstehen lassen, stehen mit
# ihren Messungen im Makefile neben der Kante. Hier steht die Kurzform und kein zweiter
# Bestand: zwei gepflegte Listen derselben Sache driften. Kurz — make lässt sich sagen,
# dass ein gefallener Check gelungen ist (`-i`, `MAKEFLAGS=i`, `.IGNORE:`, ein `-` vor
# einer Rezept-Zeile) oder dass ein Check gar nicht erst läuft (`-o`/`-W`); in beiden
# Fällen läuft dieses Rezept über rotem Stand. Ein Aufruf an make vorbei
# (`bash harness/tools/record-gates.sh`) kennt ohnehin keinen Check. NICHT dazu gehören
# `make -j` — dort bleibt der Nachweis gedeckt und nur die Reihenfolgen-Zusage fällt —
# und `make record-gates`, das dieselben Checks mitzieht wie `make gates`.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mkdir -p .harness/state
bash harness/tools/working-tree-hash.sh > .harness/state/gates-passed.diffsha
