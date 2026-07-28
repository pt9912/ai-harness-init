#!/usr/bin/env bash
# files: harness/tools/span-emit.sh
# expect: span: scheitert alles im Inneren, blockt der Emitter den Aufrufer trotzdem nicht
#
# Nimmt dem Emitter die KLEMME — und zwar BEIDE Haelften: die Subshell mit
# verworfener Ausgabe UND das abschliessende `exit 0`. Nur eine von beiden zu
# entfernen genuegt nicht: die erste Fassung dieses Falls ersetzte lediglich die
# Subshell-Zeile, `exit 0` ueberlebte, und der Fall wurde nur noch ueber die
# stderr-Vermischung in bats rot — die Exit-Klemme selbst blieb unbewacht
# (Review-Befund zu slice-059).
#
# Nach der Mutation erreicht jede innere Stoerung den Aufrufer. Bei Hooks ist der
# Aufrufer die Entscheidungs-Instanz: stdout traegt dort die Antwort ueber
# Berechtigungen, und ein Exit 2 blockt den Tool-Call — genau der Wert, mit dem
# `awk` bei einem fatalen Fehler endet. Ohne Klemme kippte fail-open zu
# fail-closed (ADR-0011 Festlegung 6).
set -euo pipefail
sed -i 's@( set -e; emit_span ) >/dev/null 2>&1 || true@set -e; emit_span@' harness/tools/span-emit.sh
sed -i '/^exit 0$/d' harness/tools/span-emit.sh
