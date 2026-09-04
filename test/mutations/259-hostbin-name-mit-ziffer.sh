#!/usr/bin/env bash
# files: Makefile
# expect: jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch von main()
# verify: test-bats
#
# HAENGT DEM NAMEN IM BEDIEN-EINSTIEG EINE ZIFFER AN: das Ziel `archive-welle`
# gibt dem Traeger danach `archive-welle2`. Der Dispatch in main() fuehrt diesen
# Namen nicht, also faellt der Aufruf in den Init-Pfad und endet dort an der
# Sperre in run() mit Exit 2 — `make archive-welle` archiviert nichts mehr.
#
# ER TRIFFT DIE NAMENS-GEWINNUNG, NICHT DIE KALIBRIERUNG. Die Zahl der
# Nennungen bleibt gleich, und jede gibt einen Namen her; ausgeglichen ist die
# Kalibrierung also weiterhin. Was faellt, ist die Dispatch-Schleife — und nur,
# solange das Namens-Muster den GANZEN Namen liest. Eine Weissliste ueber der
# Form der gueltigen Namen (`[a-z][a-z-]*`) schnitte vor der Ziffer ab, gaebe
# `archive-welle` zurueck und faende dessen `case`: der Fall bliebe gruen,
# waehrend der Bedien-Einstieg gebrochen ist.
#
# DIE FORM DES AUSDRUCKS: der Traeger-Pfad steht im Makefile als
# Variablen-Referenz, und ihr Dollar bleibt in einer Klammer-Klasse (`[$]`)
# statt vor der Klammer — sonst laese shellcheck ihn als Kommando-Substitution
# (SC2016), und eine Inline-Unterdrueckung verbietet AGENTS.md §3.2. Ersetzt
# wird ueber eine Gruppe: der Praefix wandert unveraendert zurueck, geaendert
# wird allein der Name dahinter.
set -euo pipefail
sed -i 's|^\(\t@[$](HOST_BIN) \)archive-welle |\1archive-welle2 |' Makefile
