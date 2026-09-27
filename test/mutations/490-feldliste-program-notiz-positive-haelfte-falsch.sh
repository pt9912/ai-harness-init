#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr
#
# PROGRAM-NOTIZ VERFAELSCHT NUR DIE POSITIVE HAELFTE: "das erste Wort" wird zu
# "das letzte Wort", die Verneinungs-Haelfte "nie das der ganzen Kommandozeile"
# bleibt woertlich stehen. Bindet die erste Haelfte der Zusage EINZELN
# (Reviewer-Skill "Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung
# je Teil", Befund F-1 zu slice-109-feldliste-jede-aussage-hat-ihre-quelle):
# Fall 488 rollt beide Haelften zugleich zurueck und bindet keine von beiden
# fuer sich, Fall 489 bindet nur die Verneinungs-Haelfte.
#
# ROT WIRD TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr und nur er.
set -euo pipefail
sed -i 's@das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile@das letzte Wort des ausgeführten Segments, nie das der ganzen Kommandozeile@' internal/span/fieldlist.go
