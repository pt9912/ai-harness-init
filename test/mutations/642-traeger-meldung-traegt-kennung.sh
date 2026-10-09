#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestTraegerMeldungenTragenKeineKennung
# verify: test-go
#
# EINE FEHLERMELDUNG DES TRAEGERS NENNT WIEDER EINE ADR DIESES REPOS — auf einem Fehlerpfad
# (Pfad ohne Idempotenz-Klasse), den kein Bootstrap-Test erreicht. Der Waechter liest die
# Zeichenketten-Konstanten des Quellcodes und meldet:
#   internal/emit/enforce.go:<zeile>: ADR-0007
# Gegenprobe: ohne die Pruefung der Konstanten (nur die Hilfe-Ausgabe) bleibt der Fall
# gruen (LH-QA-01).
set -euo pipefail
sed -i 's|statt konvergent zu gelten"|statt konvergent zu gelten (ADR-0007 Festlegung 3)"|' internal/emit/enforce.go
grep -q 'gelten (ADR-0007 Festlegung 3)"' internal/emit/enforce.go
