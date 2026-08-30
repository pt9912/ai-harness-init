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
# GRENZE — dieses Rezept kann über rotem Stand laufen: make lässt sich sagen, dass ein
# gefallener Check gelungen ist oder dass ein Check gar nicht erst läuft, und ein Aufruf
# an make vorbei (`bash harness/tools/record-gates.sh`) kennt ohnehin keinen Check.
# WELCHE Aufrufe und Schreibweisen das sind, steht hier nicht, sondern mit Kommando und
# Ausgabe im Kopf jenes Wächters. Eine Kurzform hier wäre eine zweite gepflegte Liste
# derselben Sache, und zwei Listen driften. Dass jene Liste abgeschlossen wäre, steht
# auch dort nicht.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mkdir -p .harness/state
bash harness/tools/working-tree-hash.sh > .harness/state/gates-passed.diffsha
