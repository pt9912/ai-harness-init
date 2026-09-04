#!/usr/bin/env bash
# files: .claude/settings.json
# expect: jedes Unterkommando hinter dem Traeger in .claude/settings.json steht im Dispatch von main()
# verify: test-bats
#
# HAENGT DEM UNTERKOMMANDO-NAMEN IM HOOK-KANAL EINE ZIFFER AN: die Hooks dieses
# Repos rufen den Traeger direkt und geben ihm danach `span-emit2`. Der Dispatch
# in main() fuehrt diesen Namen nicht, also faellt der Aufruf in den Init-Pfad
# und endet an der Sperre in run() mit Exit 2 — dem Wert, mit dem ein Hook
# blockiert.
#
# DIE KLEMME AUS ADR-0011 FESTLEGUNG 6 DECKT DAS NICHT. Sie sitzt in spanEmit()
# und klemmt, was dort ankommt; ein Name, der spanEmit() nie erreicht, liegt vor
# ihr.
#
# ER TRIFFT DIE NAMENS-GEWINNUNG, NICHT DIE KALIBRIERUNG. Drei Nennungen, drei
# Namen — die Kalibrierung bleibt ausgeglichen. Fallen kann nur die
# Dispatch-Schleife, und auch die nur, solange das Namens-Muster bis zum
# naechsten Trenner liest statt bis zum ersten Zeichen ausserhalb einer
# Weissliste: `[a-z][a-z-]*` gaebe `span-emit` zurueck, faende dessen `case`
# und liesse den Fall gruen, waehrend jeder Tool-Call den Hook blockiert.
set -euo pipefail
sed -i 's,ai-harness-init span-emit,ai-harness-init span-emit2,' .claude/settings.json
