#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestTemplates_SkipIfPresent
#
# Der skip-if-present-Writer wird auf Clobber umgebogen (der vorhandene-Fall faellt durch auf
# writeFileMode statt zu skippen): dann ueberschreibt ein Re-Lauf adopter-gefuellte Doc-Chain-
# Singletons (slice-038 Adopter-Boden). Der skip-if-present-Waechter muss rot werden.
set -euo pipefail
sed -i 's#return nil // vorhanden.*#break#' internal/emit/enforce.go
