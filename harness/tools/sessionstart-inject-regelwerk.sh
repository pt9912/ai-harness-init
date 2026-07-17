#!/usr/bin/env bash
# sessionstart-inject-regelwerk — injiziert den Modul-INDEX des Betriebsregelwerks
# aus der committet vendored Baseline (.harness/baseline/<tag>/regelwerk/README.md)
# beim Session-Start in den Agenten-Kontext (Index-only, MR-006/MR-007). Die
# Module liest der Agent on-demand aus dem Verzeichnis.
#
# Fuer den Codex-SessionStart-Hook (.codex/hooks.json): gibt die
# hookSpecificOutput.additionalContext-JSON-Form aus. Claude nutzt KEINEN Hook,
# sondern liest die Module per Pointer (CLAUDE.md) — Claude kappt Hook-Ausgaben
# bei 10k Zeichen. KEIN node/jq (LH-QA-03): JSON-String-Encoding via json-encode.awk.
# KEIN Netz-Fetch (LH-QA-02): die Baseline ist committet und auf jedem Checkout da.
#
# <tag>-Politik (MR-007): ein Tag zur Zeit. Das Verzeichnis wird ENTDECKT, nicht
# geraten — so steht der Tag-String nur in BASELINE_TAG (Makefile) und nirgends
# sonst in der Mechanik. Fehlende/mehrdeutige Baseline oder fehlendes awk ->
# SICHTBARE Warnung (statt leer) + exit 0: degradiert sichtbar, blockt KEINE
# Session.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="$here/../../.harness/baseline"
encoder="$here/json-encode.awk"

emit() {  # emit <bereits-JSON-escapter-String-Inhalt>
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"
}

# warn_encoded <roher-String>: für Meldungen, die einen ENTDECKTEN Wert (z. B.
# den Tag-Verzeichnisnamen) enthalten — dieser läuft wie der Erfolgspfad durch
# json-encode.awk, damit ein Sonderzeichen im Namen das JSON nicht bricht.
# Setzt awk + Encoder voraus (der Aufrufer prüft das vor dem ersten Einsatz).
warn_encoded() {
  local enc
  if enc="$(printf '%s' "$1" | awk -f "$encoder")"; then emit "$enc"; else
    emit "WARN: Regelwerk-Injektor degradiert (Encoding). Regelwerk NICHT als geladen voraussetzen."
  fi
}

shopt -s nullglob
dirs=("$base"/*/)
shopt -u nullglob

# Die Baseline ist committet — sie fehlt nur bei kaputtem Checkout. Es gibt
# kein 'make regelwerk-fetch' mehr (MR-007), der Hinweis nennt daher keinen
# Fetch-Befehl, sondern die tatsaechliche Ursache.
if [ "${#dirs[@]}" -eq 0 ]; then
  emit "WARN: vendored Baseline fehlt (.harness/baseline/<tag>/regelwerk/README.md). Sie ist committet — pruefe den Checkout ('make baseline-verify'). Bis dahin das Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
if [ "${#dirs[@]}" -gt 1 ]; then
  emit "WARN: mehr als ein <tag>-Verzeichnis unter .harness/baseline/ — die Setzung ist ein Tag zur Zeit (MR-007). Uneindeutig, daher kein Index injiziert; 'make baseline-verify' meldet Details. Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi

dir="${dirs[0]%/}"
tag="$(basename "$dir")"
index="$dir/regelwerk/README.md"

# Encoder-Verfügbarkeit ZUERST prüfen (vor der Index-Meldung): fehlt awk, kann
# keine Meldung, die den entdeckten $tag trägt, sicher escaped werden — dann
# nur die statische Degradations-Warnung (kein $tag, raw emit unbedenklich).
if [ ! -f "$encoder" ] || ! command -v awk >/dev/null 2>&1; then
  emit "WARN: Regelwerk-Injektor degradiert (awk oder json-encode.awk fehlt). Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
# Ab hier ist awk garantiert -> $tag-tragende Meldungen laufen durch den Encoder.
if [ ! -f "$index" ]; then
  warn_encoded "WARN: Baseline-Index fehlt ($tag/regelwerk/README.md) — die Baseline ist unvollstaendig. 'make baseline-verify' meldet Details. Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi

# Index-only (MR-006): NUR den Modul-Index (README.md) injizieren; ein
# Pointer-Praefix nennt das Verzeichnis fuer die On-demand-Lektuere der Module.
# awk-Output fangen + Exit pruefen: ein awk-Crash darf NICHT still leer
# emittieren (set -e bricht in der Kommando-Substitution nicht ab) -> sichtbare WARN.
prefix="Betriebsregelwerk (vendored Baseline $tag, MR-007) — die Module liegen unter .harness/baseline/$tag/regelwerk/<name>.md, die Ziel-Form-Templates unter .harness/baseline/$tag/templates/; lies das fuer die Aufgabe relevante Modul bei Bedarf (read-on-demand). Es folgt der Modul-Index (README.md):"
if ! encoded="$( { printf '%s\n\n' "$prefix"; cat "$index"; } | awk -f "$encoder" )"; then
  emit "WARN: Regelwerk-Encoding fehlgeschlagen (awk). Regelwerk NICHT als geladen voraussetzen."
  exit 0
fi
emit "$encoded"
