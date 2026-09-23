#!/usr/bin/env bash
# files: cmd/ai-harness-init/version.go
# expect: TestVersionFehltFallIstLaut
# verify: test-go
#
# Entstaerkt den Fehlt-Fall der Fassungs-Flaeche: der Zweig feuert nie mehr, ein
# Bau ohne Injektion meldet auf --version den LEEREN String auf stdout und Exit 0
# statt des dokumentierten Wortlauts mit Exit 2. Genau die geschwaechte Zusage,
# die ADR-0063 Festlegung 2 verwirft: still heisst ununterscheidbar von einem
# kaputten Flag, und der Pin-Wert an dieser Stelle waere die erfundene Zahl. Der
# Waechter haelt Wortlaut UND Exit an den Zustand des Binary.
set -euo pipefail
sed -i 's|if fassung == "" {|if fassung == "niemals" {|' cmd/ai-harness-init/version.go