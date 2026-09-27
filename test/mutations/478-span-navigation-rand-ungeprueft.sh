#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure
#
# NAVIGATIONS-RAND: `skipNavigation` prueft die Woerter eines Navigations-Segments nicht mehr
# auf Schlichtheit. Ein `&&` in Anfuehrungszeichen (`cd "a && b" && make`) gilt danach als
# Segment-Ende, und ein Wort hinter einem Kommentar (`cd /x # note; SECRETWORD`), einer
# Redirect-Quelle, einem Operator ohne Leerraum oder einem der Operatoren `||`, `|`, `&`
# steht als `program` im Span.
#
# DER PFAD IST STILL: entfaellt die Pruefung, bricht nichts ab und keine Fehlermeldung
# entsteht — das Programm wird nur falsch. Rot wird darum der Waechter, der die GESCHRIEBENE
# Zeile auf das Bruchstueck liest (`SECRETWORD`) und `cd` als Programm erwartet, nicht ein
# Absturz. Er traegt jedes ASCII-Zeichen ausserhalb der schlichten einzeln und die Formen, in
# denen ein Bruchstueck sonst Programm wuerde; `# expect:` nennt ihn. Die Tabelle der
# Navigations-Grenze und der mehrzeiligen Zeilen bleibt gruen.
set -euo pipefail
sed -i 's@^\t\tif !plainNavigationWord(body) {$@\t\tif false {@' internal/span/span.go
