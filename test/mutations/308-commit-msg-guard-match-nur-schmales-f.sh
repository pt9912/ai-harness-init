#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-commit-msg-guard.sh
# expect: match: --file=<pfad> -> Datei auf stdout
#
# Verengt den Flag-Teil der Match-Regex von `(-[a-zA-Z]*F|--file)` zurueck auf
# die schmale, alte Form `-F` — kombinierte Kurz-Flags (`-qF`) und die
# Lang-Form `--file`/`--file=` werden dadurch nicht mehr erkannt, waehrend
# der reine `-F <pfad>`-Fall unveraendert matcht. Die Argument-Formen
# (unquotiert, einfache/doppelte Anfuehrungszeichen) bleiben von dieser
# Mutation unberuehrt und sind damit NICHT der Gegenstand dieses Falls.
set -euo pipefail
sed -i "s@(-\[a-zA-Z\]\*F|--file)@(-F)@" .claude/hooks/pretooluse-commit-msg-guard.sh
