#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_ZielpfadeImEmittiertenLayout
#
# LEGT EINEN EMITTIERTEN ZIELPFAD INS LOKALE LAYOUT.
#
# Emittiert ist `tools/harness/`; `harness/tools/` ist der lokal adaptierte Pfad dieses Repos
# (MR-005). Ein Eintrag, der das lokale Layout emittiert, faellt im Ziel durch keine Stelle:
# die Vorbindungs-/Hook-Ketten nennen den emittierten Pfad. Geprueft wird darum die ganze
# emittierte Pfad-Menge, nicht ein kuratierter Eintrag je Skript.
set -euo pipefail
sed -i 's|"tools/harness/extract-command.awk"|"harness/tools/extract-command.awk"|' internal/emit/enforce.go
