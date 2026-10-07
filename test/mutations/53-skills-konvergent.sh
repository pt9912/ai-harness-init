#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_SkillsSkipIfPresent
#
# Die Skills unter .harness/skills/ werden wieder KONVERGENT geschrieben (writeFileMode statt
# writeSkipIfPresent): ein vom Adopter gefuellter Skill wird beim Re-Lauf ueberschrieben
# (ADR-0084 Festlegung 1 verletzt). Der Waechter muss rot werden.
set -euo pipefail
sed -i \
  's#write := writeSkipIfPresent#write := writeSkipIfPresent\n\t\tif isSkill(rel) {\n\t\t\twrite = writeFileMode\n\t\t}#' \
  internal/emit/templates.go
