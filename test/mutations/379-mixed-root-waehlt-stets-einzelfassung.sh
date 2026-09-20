#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangMixedRoot
# verify: test-go
#
# WAEHLT AM GEMISCHTEN ROOT STETS DIE EINZEL-FASSUNG: die Fassungs-Wahl liest den
# Root-Zustand nicht mehr, und das zweite Sprach-Fragment schreibt dieselben unscoped
# Rezepte wie das erste — make meldet die Ueberschreibung und die letzte Include-
# Definition gewinnt.
#
# WAS DAS MISST: die Zusage "am gemischten Root kommt das zweite Fragment in der
# gemischten Fassung" lebt in der Fassungs-Wahl des Aufrufers (cmd), nicht im Renderer —
# ohne diesen Fall waere die Wahl Text ohne Sensor (AGENTS.md 3.6). Die Renderer-Tests
# pruefen die Form der gemischten Fassung, aber nicht, dass sie GEWAEHLT wird; der
# cmd-Test haelt die Wahl fest. Die Mutation waehlt die Einzel-Fassung kompilierbar um
# (zwei Rueckgabewerte), damit der benannte Test fuer den richtigen Grund faellt und die
# Kompilation nicht schon vorher bricht.
set -euo pipefail
sed -i 's@return gen\.CodeGateFragmentMixed(lang, path, version)@return frag, nil@' cmd/ai-harness-init/main.go