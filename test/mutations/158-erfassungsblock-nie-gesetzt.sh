#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_ErfassungLiegtMitDemTraeger
#
# LAESST DEN HOOK-EINTRAG WEG: die emittierte .claude/settings.json bekommt den
# Erfassungs-Block nie, auch wenn Traeger und Wrapper liegen.
#
# Das ist die Gegenrichtung zu test/mutations/155. Der Ausfall waere STILL: Bootstrap
# gruen, Traeger da, Wrapper da — und kein Tool-Call ruft je einen von beiden. Die
# Anwesenheit des Blocks ist eine Inhalts-, keine Existenz-Aussage; ein Existenz-Waechter
# ueber .claude/settings.json bliebe hier dauerhaft gruen.
set -euo pipefail
sed -i 's/enforceContent(f.src, captured)/enforceContent(f.src, false)/' internal/emit/enforce.go
