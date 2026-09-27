#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr
#
# PROGRAM-NOTIZ VERLIERT NUR DIE VERNEINUNGS-HAELFTE: "nie das der ganzen
# Kommandozeile" entfaellt, "das erste Wort des ausgefuehrten Segments" bleibt
# stehen und richtig. Bindet die zweite Haelfte der Zusage EINZELN (Reviewer-Skill
# "Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil",
# Befund F-1 zu slice-109-feldliste-jede-aussage-hat-ihre-quelle): Fall
# 488 rollt beide Haelften zugleich zurueck und bindet keine von beiden fuer
# sich.
#
# ROT WIRD TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr und nur er.
set -euo pipefail
sed -i 's@das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile@das erste Wort des ausgeführten Segments@' internal/span/fieldlist.go
