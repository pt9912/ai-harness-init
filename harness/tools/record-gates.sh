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

# HEAD-STEMPEL (ADR-0083 Festlegungen 3/4): neben dem Hash schreibt dieses Skript die
# aufgelöste Commit-SHA von HEAD nach .harness/state/gates-passed.head — der Stop-Hook
# gibt ein Turn-Ende ohne neuen HEAD damit frei. Format von gates-passed.diffsha bleibt,
# wie es ist (weitere Leser). head_wert ermittelt den Wert genauso wie der Stop-Hook —
# Kopplung: beide Fassungen gleich halten. Ist HEAD nicht auflösbar und das Repo nicht
# eng als commitlos erkannt, endet das Skript rot, bevor es einen Stempel schreibt.
head_wert() {
  local sha alle
  if sha="$(git rev-parse --verify -q HEAD)"; then
    printf '%s\n' "$sha"
    return 0
  fi
  git symbolic-ref -q HEAD >/dev/null || return 1
  alle="$(git rev-list -n1 --all)" || return 1
  [ -z "$alle" ] || return 1
  printf '%s\n' kein-commit
}

if ! head="$(head_wert)"; then
  echo "record-gates: FEHLER — HEAD ist nicht aufloesbar, und das Repo ist nicht als commitlos erkannt (ungeborener Zweig ohne einzigen Commit) — kein Stempel geschrieben (ADR-0083 Festlegung 4)." >&2
  exit 1
fi

mkdir -p .harness/state
bash harness/tools/working-tree-hash.sh > .harness/state/gates-passed.diffsha
printf '%s\n' "$head" > .harness/state/gates-passed.head
