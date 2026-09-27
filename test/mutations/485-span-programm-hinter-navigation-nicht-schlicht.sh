#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramBehindNavigationIsAPlainWord
#
# PROGRAMM HINTER NAVIGATION: `commandProgram` prueft das erste Wort hinter einem
# uebersprungenen Navigations-Segment nicht mehr auf Schlichtheit. Danach nennt
# `cd /x && "secret token" x` das Bruchstueck `"secret` als `program`, `cd /x && $(cmd) x`
# `$(cmd)`, `cd /x && make; echo z` das Wort `make;` (SPEC-031, ADR-0011).
#
# DER PFAD IST STILL: nichts bricht ab, das Feld nennt nur ein Bruchstueck. Rot wird der
# Waechter, der jedes Zeichen des Feldes prueft und das Wort SECRETWORD in der geschriebenen
# Zeile sucht; `# expect:` nennt ihn. Er erwartet kein bestimmtes Programm — die Tabelle der
# Navigations-Grenze und die Tests der unschlichten Woerter bleiben gruen, auch wenn die
# Navigations-Grenze selbst faellt (Fall 476).
set -euo pipefail
sed -i "s@case navigated && !plainNavigationWord(f):@case navigated \&\& !plainNavigationWord(f) \&\& false:@" internal/span/span.go
