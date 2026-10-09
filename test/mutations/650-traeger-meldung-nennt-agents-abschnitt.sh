#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestTraegerMeldungenTragenKeineKennung
# verify: test-go
#
# DIE SPERRE haenger VON archive-welle NENNT WIEDER EINE ABSCHNITTSNUMMER DER AGENTS.md
# DIESES REPOS — im Ziel steht unter derselben Nummer eine andere Regel. Der Waechter liest
# die Zeichenketten-Konstanten und meldet:
#   internal/archive/vorschau.go:<zeile>: Abschnittsnummer: AGENTS.md 3
# Gegenprobe: ohne agentsAbschnittMuster in meldungsVerweise bleibt der Fall gruen
# (LH-QA-01).
set -euo pipefail
sed -i 's|mit einer ADR — Gates werden nicht ohne ADR gelockert)"|mit ADR nach AGENTS.md 3.5)"|' internal/archive/vorschau.go
grep -q 'mit ADR nach AGENTS.md 3.5)"' internal/archive/vorschau.go
