#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_SkillsSkipIfPresent
#
# Die Skills unter .harness/skills/ werden wieder KONVERGENT geschrieben (writeFileMode statt
# skillWriter): ein vom Adopter gefuellter Skill wird beim Re-Lauf ueberschrieben
# (ADR-0084 Festlegung 1 verletzt). Der Waechter muss rot werden.
set -euo pipefail
sed -i \
  's#write = skillWriter(vorlagen, notice)#write = writeFileMode#' \
  internal/emit/templates.go
