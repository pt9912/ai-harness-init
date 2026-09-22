#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt
#
# roadmap.template.md — ein Name aus der benannten Singleton-Liste des
# Waechters (singletonBezugsmenge) — wird zusaetzlich in isRecurring
# aufgenommen. Im Dispatch von planTemplates ist das unsichtbar: die
# ||-Kette schliesst kurz, die Vorlage wird einfach nicht mehr emittiert.
# Der Waechter sieht es, weil er jede Menge einzeln auswertet (ADR-0057
# Festlegung 1, Rot-Bedingung 2: Disjunktheit) — roadmap.template.md steht
# danach in ZWEI Mengen zugleich. Kompiliert weiter.
set -euo pipefail
sed -i 's/"welle-results.template.md", "MR-NNN-titel.template.md":/"welle-results.template.md", "MR-NNN-titel.template.md", "roadmap.template.md":/' internal/emit/templates.go
