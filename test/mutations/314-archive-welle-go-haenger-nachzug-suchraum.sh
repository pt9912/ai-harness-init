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
#
# Anker ist das Muster "range Suchraum(dateien)", nicht eine Zeilennummer: ein
# Zeilen-Anker wandert mit jeder vorangestellten Kommentarzeile und kann eine
# zufaellig passende Verschiebung auf die SUCHRAUM-Kommentarzeile in Haenger
# statt auf den Code lenken. Das Muster ist eindeutig
# (grep -c 'range Suchraum(dateien)' internal/archive/scan.go -> 1).
set -euo pipefail
sed -i 's/range Suchraum(dateien)/range SuchraumNachzug(dateien)/' internal/archive/scan.go
