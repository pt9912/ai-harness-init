#!/usr/bin/env bash
# files: harness/tools/extract-agent-call.awk
# expect: extract: subagent_type in VERSCHACHTELTEM Objekt zaehlt nicht (Attrappe danach)
#
# Nimmt dem Key-Stack die ELTERN-PRUEFUNG fuer `subagent_type`: danach zaehlt der
# Schluessel in JEDER Tiefe und unter JEDEM Elternschluessel, nicht mehr nur auf dem
# Pfad `tool_input -> subagent_type`.
#
# Das ist der Griff, den ein sed/grep-Extraktor machen wuerde — und die Payload eines
# Agent-Aufrufs traegt Freitext (`prompt`, `description`), in dem der Aufrufer den
# Schluessel frei setzen kann. Der Guard entschiede dann ueber die falsche Groesse.
#
# Rot werden in test/agent-guard.bats die beiden „(Attrappe danach)"-Faelle zu
# `subagent_type` (verschachteltes Objekt und Top-Level). NICHT die
# „(Attrappe davor)"-Fassung: dort ueberschreibt der echte Wert die Attrappe auch in
# der kaputten Fassung („letzter Treffer gewinnt"), sie bleibt gruen. Der Test sagt
# das an der Stelle selbst; beim Formulieren dieses Kopfes ist es nicht zu
# verwechseln.
#
# ZWEIZEILIGER ANKER: die Bedingung ist umbrochen. `N` zieht die Folgezeile in den
# Puffer, `\n` im Muster verlangt sie ausdruecklich — ohne das `\n` haengt es davon
# ab, ob `.` einen Umbruch matcht, und ein halb ersetzter Ausdruck waere ein
# awk-Syntaxfehler statt einer Mutation.
set -euo pipefail
sed -i '/curkey\[depth\] == "subagent_type" &&$/{N;s@.*\n.*@        } else if (curkey[depth] == "subagent_type") {@;}' harness/tools/extract-agent-call.awk
