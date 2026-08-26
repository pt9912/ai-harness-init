#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_GrenzeAufrufform
# verify: test-go
#
# DER ERSTE STEHENDE GRENZ-SATZ FAELLT AUS DEM DOKUMENT: dass die emittierte Ebene keinen
# Waechter ueber die Aufrufform des Agenten-Werkzeugs fuehrt.
#
# Drei Saetze, drei Zusagen, drei Faelle — eine Zusage mit „und" hat mehrere Bruchstellen,
# und ein einziger Fall belegte nur eine davon. Ohne diesen Satz liest ein Adopter eine
# besetzte Rollen-Achse als zugesagt, waehrend sie auf seiner Disziplin ruht.
set -euo pipefail
sed -i 's@return \[\]string{limitAgentGuard, limitCounters, limitStore}@return []string{limitCounters, limitStore}@' internal/span/fieldlist.go
