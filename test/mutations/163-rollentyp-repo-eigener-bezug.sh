#!/usr/bin/env bash
# files: internal/emit/templates/agents/planner.md
# expect: TestAgents_KeineRepoEigenenBezuege
# verify: test-go
#
# TRAEGT EINE SLICE-KENNUNG DIESES REPOS IN EINEN EMITTIERTEN ROLLEN-TYP.
#
# Das ist die erste der fuenf Klassen aus ADR-0022 Festlegung 3: eine Kennung, die nur
# hier aufloest. Im Zielrepo benennt `slice-042` keinen Vorgang — der Satz zeigt ins
# Leere, und der Typ traegt damit Repo-Inhalt statt eines Kontext-Zuschnitts. Genau das
# unterscheidet die generische Fassung von der Kopie unserer sechs Dateien.
#
# Die uebrigen vier Klassen (Adaptions-Kennung, Entscheidungs-Kennung, Dogfood-Pfad,
# Dogfood-Ziel) traegt derselbe Waechter; jede fuehrt ihren eigenen Positiv-Fall im Test.
set -euo pipefail
sed -i 's|^Du bist der \*\*Planner\*\* (Modul 8) im Harness-Prozess dieses Repos\.$|Du bist der **Planner** (Modul 8) im Harness-Prozess dieses Repos — der Schnitt aus slice-042 gilt weiter.|' internal/emit/templates/agents/planner.md
