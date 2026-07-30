#!/usr/bin/env bash
# files: harness/tools/extract-agent-call.awk
# expect: extract: run_in_background ausserhalb tool_input zaehlt nicht (Attrappe danach)
#
# Dasselbe fuer den NACKTEN Literal: nimmt `flushlit()` die Elternpruefung, sodass
# `run_in_background` in jeder Tiefe zaehlt statt nur unter `tool_input`.
#
# `run_in_background` ist kein String, sondern ein Literal (true/false) — der
# String-Scanner allein sieht es nicht, dafuer gibt es den lit-Puffer. Damit ist es
# der zweite, getrennte Weg in die Guard-Entscheidung, und er braucht seinen eigenen
# Zahn: Fall 121 laesst diese Zeile unberuehrt.
#
# Rot wird in test/agent-guard.bats „run_in_background ausserhalb tool_input zaehlt
# nicht (Attrappe danach)" — die Fassung mit der Attrappe HINTER dem echten Wert.
# Eine Attrappe davor bliebe gruen („letzter Treffer gewinnt", s. test/mutations/121).
#
# ZWEIZEILIGER ANKER wie in test/mutations/121.
set -euo pipefail
sed -i '/curkey\[depth\] == "run_in_background" &&$/{N;s@.*\n.*@  if (curkey[depth] == "run_in_background") {@;}' harness/tools/extract-agent-call.awk
