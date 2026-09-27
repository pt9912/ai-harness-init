#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandArgcEndsWithItsSegment
#
# SEMIKOLON-ENDE: `closesSegment` kennt ein Feld auf `;` nicht mehr als Ende seines Segments.
# Danach ist `argc` fuer `make; echo x y` 3 statt 0 (das Programm-Feld schliesst sein Segment)
# und fuer `make gates; echo x y` 4 statt 1 (das Feld `gates;` beendet es und zaehlt mit).
#
# ROT WIRD DIE TABELLE DER ARGC-GRENZE an den Zeilen mit Feld auf `;`; `# expect:` nennt sie.
# Das Zeilenende als Segment-Ende steht in derselben Funktion und ist von dieser Mutation
# nicht getroffen (Fall 481).
set -euo pipefail
sed -i 's@^\treturn strings.HasSuffix(w.fields\[k\], ";") || w.eol\[k\]$@\treturn w.eol[k]@' internal/span/span.go
