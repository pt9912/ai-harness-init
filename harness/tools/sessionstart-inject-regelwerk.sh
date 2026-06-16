#!/usr/bin/env bash
# sessionstart-inject-regelwerk — injiziert den Modul-INDEX des wortgleichen
# Betriebsregelwerks (.harness/cache/agents-regelwerk/README.md) beim
# Session-Start in den Agenten-Kontext (Index-only, MR-006). Die Module liest
# der Agent on-demand aus dem Cache-Verzeichnis.
#
# Fuer den Codex-SessionStart-Hook (.codex/hooks.json): gibt die
# hookSpecificOutput.additionalContext-JSON-Form aus. Claude nutzt KEINEN Hook,
# sondern liest die Module per Pointer (CLAUDE.md) — Claude kappt Hook-Ausgaben
# bei 10k Zeichen. KEIN node/jq (LH-QA-03): JSON-String-Encoding via json-encode.awk.
# KEIN Netz-Fetch (LH-QA-02): nur der lokale, ZIP-sha256-gepinnte Cache, den
# `make regelwerk-fetch` (gitignored) befuellt.
#
# Fehlendes Cache-Verzeichnis/Index (vor dem Fetch) oder fehlendes awk -> SICHTBARE
# Warnung mit dem Fetch-Befehl (statt leer) + exit 0: degradiert sichtbar, blockt
# KEINE Session. Kein Netz im Hook. Mechanik: conventions.md MR-006 (ergaenzt MR-004).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache_dir="$here/../../.harness/cache/agents-regelwerk"
index="$cache_dir/README.md"
encoder="$here/json-encode.awk"

emit() {  # emit <bereits-JSON-escapter-String-Inhalt>
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"
}

# Fehlendes Cache-Verzeichnis/Index / fehlendes Tooling -> SICHTBARE Warnung
# (statt leer), exit 0: degradiert sichtbar (kein stilles Schlucken), blockt
# KEINE Session. Kein Netz-Fetch hier (LH-QA-03) — der Hinweis nennt nur den
# Maintenance-Befehl.
if [ ! -f "$index" ]; then
  emit "WARN: Regelwerk-Cache fehlt (.harness/cache/agents-regelwerk/README.md). Fuehre 'make regelwerk-fetch' aus und starte die Session neu — bis dahin das Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
if [ ! -f "$encoder" ] || ! command -v awk >/dev/null 2>&1; then
  emit "WARN: Regelwerk-Injektor degradiert (awk oder json-encode.awk fehlt). Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi

# Index-only (MR-006): NUR den Modul-Index (README.md) injizieren; ein
# Pointer-Praefix nennt das Cache-Verzeichnis fuer die On-demand-Lektuere der
# Module. awk-Output fangen + Exit pruefen: ein awk-Crash darf NICHT still leer
# emittieren (set -e bricht in der Kommando-Substitution nicht ab) -> sichtbare WARN.
prefix='Betriebsregelwerk (Split-Modul-Cache, MR-006) — die Module liegen unter .harness/cache/agents-regelwerk/<name>.md; lies das fuer die Aufgabe relevante Modul bei Bedarf (read-on-demand). Es folgt der Modul-Index (README.md):'
if ! encoded="$( { printf '%s\n\n' "$prefix"; cat "$index"; } | awk -f "$encoder" )"; then
  emit "WARN: Regelwerk-Encoding fehlgeschlagen (awk). Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
emit "$encoded"
