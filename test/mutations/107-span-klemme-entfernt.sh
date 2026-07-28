#!/usr/bin/env bash
# files: harness/tools/span-emit.sh
# expect: span: scheitert alles im Inneren, blockt der Emitter den Aufrufer trotzdem nicht
#
# Nimmt dem Emitter die KLEMME: statt den Rumpf in einer Subshell mit verworfener
# Ausgabe und geschlucktem Exit-Code zu fahren, laeuft er direkt. Damit erreicht
# jede innere Stoerung den Aufrufer — und bei Hooks ist der Aufrufer die
# Entscheidungs-Instanz: stdout ist dort der Kanal, auf dem ueber Berechtigungen
# geantwortet wird, und ein Exit 2 blockt den Tool-Call.
#
# Das ist keine Kosmetik. `awk` endet bei einem fatalen Fehler mit genau diesem
# Exit 2. Ohne Klemme legte also ein Tippfehler im Scanner den Lauf still, den
# die Telemetrie nur beobachten soll — fail-open waere zu fail-closed gekippt
# (ADR-0011 Festlegung 6).
set -euo pipefail
sed -i 's@( emit_span ) >/dev/null 2>&1 || true@emit_span@' harness/tools/span-emit.sh
