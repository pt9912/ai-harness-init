#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_SkillsConvergent
#
# Die .harness/skills/*-KONVERGENT-Ausnahme wird neutralisiert (HasPrefix -> false): dann laufen
# die Skills wie der uebrige Satz als skip-if-present, und ein Baseline-Bump der tool-eigenen
# Skills wird beim Re-Init NICHT geheilt (ADR-0007 Z.100 verletzt). Der Waechter muss rot werden.
set -euo pipefail
sed -i 's#strings.HasPrefix(rel, ".harness/skills/")#false#' internal/emit/templates.go
