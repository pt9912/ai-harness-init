#!/usr/bin/env bash
# files: .claude/settings.json
# expect: jedes Unterkommando hinter dem Traeger in .claude/settings.json steht im Dispatch von main()
# verify: test-bats
#
# NIMMT DEN UNTERKOMMANDO-NAMEN GANZ WEG: die Hooks rufen danach den blanken
# Traeger. Der Dispatch in main() greift ohne Argument nicht, os.Getwd() liefert
# das Arbeitsverzeichnis, und run() bekommt ein leeres Argument-Feld — also kein
# Positionsargument, an dem die Sperre haelt. Der Init-Pfad laeuft: bootstrap()
# legt bei jedem Tool-Call ein Repo im Arbeitsverzeichnis an.
#
# ER TRIFFT DIE SELBST-KALIBRIERUNG, NICHT DIE DISPATCH-SCHLEIFE. Nach der
# Mutation traegt die Datei drei Nennungen des Traegers und keinen einzigen
# Namen dahinter; die Schleife liefe leer und haette nichts zu pruefen. Nur weil
# `nennungen` JEDES Vorkommen des Traeger-Namens zaehlt und nicht bloss die
# Vorkommen mit folgendem Namen, faellt der Fall hier.
set -euo pipefail
sed -i 's,ai-harness-init span-emit,ai-harness-init,' .claude/settings.json
