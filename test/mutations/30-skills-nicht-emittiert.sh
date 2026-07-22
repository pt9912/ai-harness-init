#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Der .harness/skills/-Ausschluss kehrt in inScope zurueck (an den project-readme-
# Case gehaengt) -> die Reviewer-/Closure-Skills werden nicht mehr emittiert
# (Rueckfall vor slice-030). Der emittierte Bestand verliert die 2 Skills -> der
# Vollstaendigkeits-Test wird rot. Kompiliert weiter (strings.HasPrefix bleibt via
# StripHintBlock im Paket genutzt) -- sonst waere das Rot ein Build-Fehler.
set -euo pipefail
sed -i 's#case rel == "project-readme.template.md":#case rel == "project-readme.template.md" || strings.HasPrefix(rel, ".harness/skills/"):#' internal/emit/templates.go
