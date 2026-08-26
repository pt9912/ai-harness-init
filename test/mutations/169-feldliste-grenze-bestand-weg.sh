#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_GrenzeUeberDenBestand
# verify: test-go
#
# DER DRITTE STEHENDE GRENZ-SATZ FAELLT AUS DEM DOKUMENT: dass ueber den Bestand nichts
# zugesagt ist — gitignored, aber nicht verschluesselt, nicht zugriffsbeschraenkt, und
# Pfadnamen ausdruecklich nicht als unkritisch zugesagt.
#
# Von den dreien der Satz mit dem schwaechsten Rueckhalt: LH-FA-10 §Redaktion verlangt
# ihn, ADR-0022 Festlegung 6 Stueck 3 verlangt ihn als GESCHRIEBEN — einen stehenden Ort
# nennt ihm keine der beiden Quellen. Dieser Fall haelt fest, dass der gewaehlte Ort ihn
# auch traegt.
set -euo pipefail
sed -i 's@return \[\]string{limitAgentGuard, limitCounters, limitStore}@return []string{limitAgentGuard, limitCounters}@' internal/span/fieldlist.go
