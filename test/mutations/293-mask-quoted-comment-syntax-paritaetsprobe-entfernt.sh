#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestStripCommentHints
#
# ENTFERNT DIE WOHLGEFORMTHEITS-PROBE: die Zeile mit ungerader Backtick-Zahl wird
# nicht mehr uebersprungen, jede Zeile wird maskiert.
#
# Ohne die Probe bindet ein einzelner, unpaarig stehender Backtick den naechsten,
# UNABHAENGIGEN Backtick als Schliesser und reisst echten Text — samt einer echten
# Kommentar-Hilfe dazwischen — in eine (falsche) maskierte Spanne; die Hilfe
# ueberlebt dann den Emit statt zu fallen (Review-Klasse
# Vorwaerts-Korrektur-oeffnet-die-Gegenrichtung, Runde 3 MEDIUM-1).
set -euo pipefail
sed -i 's/if strings\.Count(line, "`")%2 != 0 {/if false {/' internal/emit/templates.go
