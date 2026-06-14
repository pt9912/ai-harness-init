#!/usr/bin/env bash
# sessionstart-inject-regelwerk — injiziert das wortgleiche Betriebsregelwerk
# (.harness/cache/agents-regelwerk.md) beim Session-Start in den Agenten-Kontext.
#
# Fuer den Codex-SessionStart-Hook (.codex/hooks.json): gibt die
# hookSpecificOutput.additionalContext-JSON-Form aus. Claude nutzt KEINEN Hook,
# sondern liest den Cache per Pointer (CLAUDE.md) — Claude kappt Hook-Ausgaben
# bei 10k Zeichen. KEIN node/jq (LH-QA-03): JSON-String-Encoding via json-encode.awk.
# KEIN Netz-Fetch (LH-QA-02): nur die lokale, sha256-gepinnte Kopie, die
# `make regelwerk-fetch` (gitignored) befuellt.
#
# Fehlender Cache (vor dem Fetch) oder fehlendes awk -> SICHTBARE Warnung mit dem
# Fetch-Befehl (statt leer) + exit 0: degradiert sichtbar, blockt KEINE Session.
# Kein Netz im Hook. Mechanik: conventions.md MR-004.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache="$here/../../.harness/cache/agents-regelwerk.md"
encoder="$here/json-encode.awk"

emit() {  # emit <bereits-JSON-escapter-String-Inhalt>
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"
}

# Fehlender Cache / fehlendes Tooling -> SICHTBARE Warnung (statt leer), exit 0:
# degradiert sichtbar (kein stilles Schlucken), blockt KEINE Session. Kein
# Netz-Fetch hier (LH-QA-03) — der Hinweis nennt nur den Maintenance-Befehl.
if [ ! -f "$cache" ]; then
  emit "WARN: Regelwerk-Cache fehlt (.harness/cache/agents-regelwerk.md). Fuehre 'make regelwerk-fetch' aus und starte die Session neu — bis dahin das Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
if [ ! -f "$encoder" ] || ! command -v awk >/dev/null 2>&1; then
  emit "WARN: Regelwerk-Injektor degradiert (awk oder json-encode.awk fehlt). Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi

# awk-Output fangen + Exit pruefen: ein awk-Crash darf NICHT still leer emittieren
# (set -e bricht in der Kommando-Substitution nicht ab) -> sichtbare WARN.
if ! encoded="$(awk -f "$encoder" < "$cache")"; then
  emit "WARN: Regelwerk-Encoding fehlgeschlagen (awk). Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
emit "$encoded"
