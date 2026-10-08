#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet
#
# DIE AUSSAGE NENNT EIN VERZEICHNIS MIT FREMDEM PRAEFIX: die Meldung zu harness/mk/.gitattributes
# spricht von den Dateien in tools/harness/mk/ — ein Name, der auf das erwartete Verzeichnis endet.
# Der Test verlangt das Verzeichnis hinter dem Pfad an einer Wortgrenze.
set -euo pipefail
sed -i 's|zeilenendenMeldung("harness/mk")|zeilenendenMeldung("tools/harness/mk")|' internal/emit/zeilenenden.go
