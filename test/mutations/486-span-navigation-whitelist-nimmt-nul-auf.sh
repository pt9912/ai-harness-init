#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure
#
# WHITELIST-GRENZE, ERWEITERT: `plainNavigationChars` nimmt NUL als schlichtes Zeichen auf.
# Danach ist `cd x<NUL>y && make` ein Navigations-Segment mit schlichten Woertern und wird
# uebersprungen: `program` nennt `make` statt `cd`. Jedes Zeichen, das die Whitelist verlaesst
# oder betritt, verschiebt die Grenze, an der die Zerlegung das Ende des Segments nicht mehr
# sicher findet (SPEC-031).
#
# ROT WIRD DER SWEEP UEBER DIE ASCII-ZEICHEN 0 BIS 127 und nur er; `# expect:` nennt ihn. Er
# traegt die erwartete Menge als eigene Konstante und faerbt jedes Zeichen, das der Code
# zusaetzlich als schlicht fuehrt.
set -euo pipefail
sed -i 's@^const plainNavigationChars = "@const plainNavigationChars = "\\x00@' internal/span/span.go
