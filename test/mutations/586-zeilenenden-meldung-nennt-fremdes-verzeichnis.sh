#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet
#
# DIE AUSSAGE NENNT EIN FREMDES VERZEICHNIS: die Meldung zu .githooks/.gitattributes nennt den
# belegten Pfad weiter, ihr Aussagesatz spricht aber von den Dateien in .claude/hooks/. Der Pfad
# selbst traegt .githooks/; der Test verlangt das Verzeichnis im Text hinter dem Pfad.
set -euo pipefail
sed -i 's|zeilenendenMeldung(".githooks")|zeilenendenMeldung(".claude/hooks")|' internal/emit/zeilenenden.go
