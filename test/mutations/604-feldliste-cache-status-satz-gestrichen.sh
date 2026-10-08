#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_CacheStatusNurAusSubagentImVordergrund
#
# DIE FELDLISTE VERLIERT DEN SATZ UEBER DEN CACHE-STATUS: dass nur ein Subagenten-Aufruf im
# Vordergrund ihn liefert und jeder andere Span die Kennzeichnung traegt (SPEC-055, SPEC-087 in
# spec/spezifikation.md §5).
set -euo pipefail
sed -i 's@\*\*Den Cache-Status liefert nur ein Subagenten-Aufruf im Vordergrund.\*\*@**gestrichen**@' internal/span/fieldlist.go
