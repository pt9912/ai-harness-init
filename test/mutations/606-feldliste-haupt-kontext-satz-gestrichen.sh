#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_HauptKontextTraegtKeineZahl
#
# DIE FELDLISTE VERLIERT DEN SATZ, DASS DER HAUPT-KONTEXT KEINE ZAHL TRAEGT (SPEC-049 in
# spec/spezifikation.md §5).
set -euo pipefail
sed -i 's@\*\*Der Haupt-Kontext trägt keine Zahl.\*\*@**gestrichen**@' internal/span/fieldlist.go
