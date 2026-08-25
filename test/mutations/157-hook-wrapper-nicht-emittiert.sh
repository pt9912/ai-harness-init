#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_ErfassungLiegtMitDemTraeger
#
# LAESST DEN HOOK-WRAPPER WEG: captureFiles() liefert eine leere Menge.
#
# Der Waechter misst das PRAEFIX SAMT BESTAND unter .claude/hooks/ im Ziel, nicht einen
# geratenen Dateinamen — eine Stichprobe auf einen Namen, den der Emit nie schreibt,
# koennte unter keiner Mutation rot werden (AGENTS.md 3.6). Ohne Wrapper zeigten die
# Hook-Eintraege in .claude/settings.json auf eine Datei, die nicht existiert.
set -euo pipefail
sed -i '/{"templates\/enforce\/span-emit.sh", ".claude\/hooks\/span-emit.sh", 0o755},/d' internal/emit/enforce.go
