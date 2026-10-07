#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_SkillsSkipIfPresent
#
# Die Skills unter .harness/skills/ werden wieder KONVERGENT geschrieben (writeFileMode statt
# writeSkipIfPresent): ein vom Adopter gefuellter Skill wird beim Re-Lauf ueberschrieben
# (ADR-0084 Festlegung 1 verletzt). Der Waechter muss rot werden.
set -euo pipefail
sed -i 's#if err := writeSkipIfPresent(targetDir, rel, content, 0o644); err != nil {#write := writeSkipIfPresent; if isSkill(rel) { write = writeFileMode }; if err := write(targetDir, rel, content, 0o644); err != nil {#' internal/emit/templates.go
