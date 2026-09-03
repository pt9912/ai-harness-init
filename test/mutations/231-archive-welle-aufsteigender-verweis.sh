#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: eingehend aufsteigend: '](../<datei>)' im Stub bekommt das Welle-Segment
#
# Nimmt der aufsteigenden Ersetzung das Welle-Segment: sie zaehlt weiter und
# schreibt weiter, aber sie schreibt denselben Pfad zurueck. Betroffen ist die
# Form, die das Werkzeug SELBST in die Stubs setzt — der Folge-Slice-Link auf
# eine noch flach in done/ liegende Datei. Beim naechsten Archivierungslauf
# zoege dieses Ziel eine Ebene tiefer, der Link zeigte ins Leere, und keine der
# beiden anderen Regeln erreichte ihn.
set -euo pipefail
sed -i "s|\](\.\./\${welle}/\${base})|](../\${base})|" harness/tools/archive-welle.sh
