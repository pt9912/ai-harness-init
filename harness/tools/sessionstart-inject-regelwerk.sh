#!/usr/bin/env bash
# sessionstart-inject-regelwerk — injiziert das gepinnte Betriebsregelwerk
# (harness/agents-regelwerk.cache.md) beim Session-Start in den Agenten-Kontext.
#
# Agent-neutral: gibt dieselbe hookSpecificOutput.additionalContext-JSON-Form
# fuer Claude Code (.claude/settings.json) und Codex CLI (.codex/hooks.json)
# aus. KEIN node/jq (LH-QA-03): JSON-String-Encoding via json-encode.awk.
# KEIN Netz-Fetch (LH-QA-02): nur die lokale, gepinnte Kopie.
#
# Fehlender Cache oder fehlendes awk -> leerer additionalContext + exit 0:
# degradiert leise, blockt KEINE Session. Mechanik: conventions.md MR-004.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache="$here/../../harness/agents-regelwerk.cache.md"
encoder="$here/json-encode.awk"

emit() {  # emit <bereits-JSON-escapter-String-Inhalt>
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"
}

if [ ! -f "$cache" ] || [ ! -f "$encoder" ] || ! command -v awk >/dev/null 2>&1; then
  emit ""
  exit 0
fi

emit "$(awk -f "$encoder" < "$cache")"
