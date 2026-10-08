#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_BestandNurAusdruecklichGeraeumt
#
# DIE FELDLISTE VERLIERT DEN SATZ, DASS DER BESTAND NUR AUSDRUECKLICH MIT make span-clean
# GERAEUMT WIRD (SPEC-057 in spec/spezifikation.md §5).
set -euo pipefail
sed -i 's@\*\*Der Bestand wird nie nebenbei geräumt.\*\*@**gestrichen**@' internal/span/fieldlist.go
