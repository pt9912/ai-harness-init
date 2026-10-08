#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_PRNummerBewusstNichtImSchema
#
# DIE FELDLISTE VERLIERT DEN SATZ, DASS EINE PR-NUMMER BEWUSST NICHT IM SCHEMA STEHT
# (SPEC-056 in spec/spezifikation.md §5, MR-077).
set -euo pipefail
sed -i 's@\*\*Eine PR-Nummer steht bewusst nicht im Schema.\*\*@**gestrichen**@' internal/span/fieldlist.go
