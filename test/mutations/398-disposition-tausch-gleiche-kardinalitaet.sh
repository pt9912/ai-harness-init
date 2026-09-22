#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt
#
# gate.template.md wird in isRecurring GEGEN roadmap.template.md getauscht —
# beide aus der Bezugsmenge, die Kardinalitaet von isRecurring bleibt bei elf
# Eintraegen unveraendert. Ein Waechter, der nur die ANZAHL der Namen zaehlt,
# bliebe hier gruen. Dieser faellt zweifach (ADR-0057 Festlegung 1,
# Rot-Bedingung 3): gate.template.md steht danach in KEINER der vier Mengen
# (Vollstaendigkeit bricht), roadmap.template.md — schon in der benannten
# Singleton-Liste des Waechters — steht zugleich in isRecurring
# (Disjunktheit bricht). Kompiliert weiter.
set -euo pipefail
sed -i 's/"observation.template.md", "gate.template.md":/"observation.template.md", "roadmap.template.md":/' internal/emit/templates.go
