#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach
# verify: test-go
#
# ADR-0033 Abnahme-Kriterium 3: nimmt der aufsteigenden Ersetzung ihr
# Welle-Segment. Sie zaehlt weiter und schreibt weiter — aber sie schreibt
# denselben Pfad zurueck.
#
# Betroffen ist die Form, die das Werkzeug SELBST in die Stubs setzt: der
# Folge-Slice-Link auf eine noch flach in done/ liegende Datei
# (SlicePfadRelativ liefert dafuer "../<datei>.md"). Beim naechsten
# Archivierungslauf zieht dieses Ziel eine Ebene tiefer, der Link zeigt ins
# Leere, und keine der beiden anderen Regeln erreicht ihn — die Praefix-Regel
# ankert am Literal "done/", das hier fehlt, die geschwister-relative laeuft
# ueber die flachen done/*.md.
set -euo pipefail
sed -i 's|"](\.\./"+welleID+"/"+base+")"|"](../"+base+")"|' internal/archive/refs.go
