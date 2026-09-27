#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandArgcEndsWithItsSegment
#
# ZEILEN-ENDE: `closesSegment` kennt das Ende der Zeile nicht mehr als Ende eines Segments.
# Danach ist `argc` fuer `make gates` + Zeilenende + `echo x y` 4 statt 1 und fuer `make` +
# Zeilenende + `echo x y` 3 statt 0: die Woerter der naechsten Zeile zaehlen zum Segment
# davor (SPEC-021: die Argument-Anzahl DIESES Segments).
#
# ROT WIRD DIE TABELLE DER ARGC-GRENZE an den Zeilen mit Zeilenende; `# expect:` nennt sie.
# Das Feld auf `;` als Segment-Ende ist von dieser Mutation nicht getroffen (Fall 480).
set -euo pipefail
sed -i 's@^\treturn strings.HasSuffix(w.fields\[k\], ";") || w.eol\[k\]$@\treturn strings.HasSuffix(w.fields[k], ";")@' internal/span/span.go
