#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure
#
# NAVIGATIONS-RAND: `skipNavigation` prueft ein Navigations-Segment nicht mehr auf die Zeichen
# aus `navigationUnsureChars`. Ein `&&` in Anfuehrungszeichen (`cd "a && b" && make`) gilt
# danach als Segment-Ende, und ein Stueck des Arguments (`b"`) steht als `program` im Span.
#
# DER PFAD IST STILL: entfaellt die Pruefung, bricht nichts ab und keine Fehlermeldung
# entsteht — das Programm wird nur falsch. Rot wird darum der Waechter, der die GESCHRIEBENE
# Zeile auf das Bruchstueck liest (`SECRET`) und `cd` als Programm erwartet, nicht ein Absturz.
set -euo pipefail
sed -i 's@^\t\tcase strings.ContainsAny(f, navigationUnsureChars):$@\t\tcase false:@' internal/span/span.go
