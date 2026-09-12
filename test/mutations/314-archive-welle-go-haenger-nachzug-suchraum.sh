#!/usr/bin/env bash
# files: internal/archive/scan.go
# expect: TestHaengerFindetVerweisAusADRTrotzNachzugAusnahme
# verify: test-go
#
# Verengt Haenger auf SuchraumNachzug — denselben Suchraum wie VerweisFund und
# Nachziehen. Eine Accepted-ADR mit einem lebenden Verweis auf eine
# archivierte Slice-Datei verschwindet damit lautlos aus der
# Haenger-Vorpruefung: der schreibende Lauf archiviert einen Report, den die
# ADR noch verlinkt, ohne dass die Sperre greift.
#
# TestVerweisFundUndNachziehenUebergehenAcceptedADR bleibt unveraendert
# wirksam — sie prueft ausschliesslich VerweisFund/Nachziehen, nicht Haenger.
set -euo pipefail
sed -i '180s/Suchraum(/SuchraumNachzug(/' internal/archive/scan.go
