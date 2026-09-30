#!/usr/bin/env bash
# files: spec/spezifikation.md
# expect: keine SPEC-Zeile traegt eine leere letzte Zelle
# verify: test-bats
#
# LEERT DIE ZELLE `Praezisiert` EINER SPEC-ZEILE (SPEC-057): der Anker-Link entfaellt, die
# Zelle bleibt als Zellgrenze stehen. Die Kopfzeilen bleiben unberuehrt, damit der Fall nur
# die Zusage der nicht leeren Zelle trifft und nicht die der Spalte (Fall 501). `make
# docs-check` meldet diese Lage nicht.
set -euo pipefail
sed -i '/^| .SPEC-057. /s@| \[LH-FA-10\]([^)]*) |$@|  |@' spec/spezifikation.md
