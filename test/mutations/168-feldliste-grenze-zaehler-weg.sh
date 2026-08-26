#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_GrenzeVerbrauchsZaehler
# verify: test-go
#
# DER ZWEITE STEHENDE GRENZ-SATZ FAELLT AUS DEM DOKUMENT: dass die Verbrauchs-Zaehler aus
# der Mechanik des Agenten-Werkzeugs nicht kommen und kein Lauf des Adopters sie
# herbeifuehrt.
#
# Er ist die Einloesung von ADR-0021 Folgepflicht 6 im Ziel. Eine Abdeckungs-Zeile in
# einem Bericht meldet einen ZUSTAND und laesst offen, ob er morgen anders ist; erst
# dieser Satz nennt die GRENZE — und er gilt auch dann, wenn niemand einen Bericht ruft.
set -euo pipefail
sed -i 's@return \[\]string{limitAgentGuard, limitCounters, limitStore}@return []string{limitAgentGuard, limitStore}@' internal/span/fieldlist.go
