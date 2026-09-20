#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_ScriptsExecutable
#
# NIMMT EINEM HOOK-SKRIPT DEN AUSFUEHR-MODUS: der Eintrag fuer
# .claude/hooks/stop-require-gates.sh traegt in enforceFiles() 0o755 statt 0o644 fuer
# Nicht-Skripte — diese Mutation setzt ihn auf 0o644. Ein nicht ausfuehrbarer Stop-Hook
# waere eine leere Zusage: Claude ruft ihn je Abschluss auf, und ein Skript ohne x-Bit
# scheitert am Start, nicht am Inhalt.
set -euo pipefail
sed -i 's@dst: "\.claude/hooks/stop-require-gates\.sh", mode: 0o755@dst: ".claude/hooks/stop-require-gates.sh", mode: 0o644@' internal/emit/enforce.go
