#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestGenerate_CppHexsliceIncludesAreModuleRootRelative
#
# Nimmt den `src/`-Praefix aus den Schicht-Includes des generierten C++-hexSlice-Skeletts.
# Der Code UEBERSETZT danach weiter (mit dem Modul-Root im Include-Pfad findet der
# Praeprozessor die Header ueber den kuerzeren Pfad nicht — aber selbst wo er es taete),
# und genau das ist die Falle: a-check loest NUR modul-root-relative Include-Strings auf.
# Praefixlose Includes sind ihm UNSICHTBAR, ein verbotener Import faellt still durch und
# das Arch-Gate meldet 0 Befunde (gemessen 2026-07-27 gegen das gepinnte Image). Ohne
# diesen Anker waere die Gate-Sichtbarkeit eine reine Behauptung (LH-QA-01/AGENTS.md §3.6).
set -euo pipefail
sed -i 's|#include "src/hexagon/|#include "hexagon/|g' internal/gen/cpp.go
