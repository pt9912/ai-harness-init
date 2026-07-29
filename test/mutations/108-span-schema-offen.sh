#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestUnknownToolStaysSilent
#
# Oeffnet den fail-closed Default: ein Werkzeug, das NICHT namentlich in der
# MR-018-Tabelle steht, wird behandelt wie ein Kommando-Werkzeug — es gibt also
# Argumente preis.
#
# Das ist die Achse, an der ADR-0011 Festlegung 2 haengt: erfasst wird nach dem
# WERKZEUG-Namen, nicht nach dem Feld-Namen. Haengt es am Feld, gibt jedes unbekannte
# Werkzeug, das zufaellig `command` fuehrt, seine Kommandozeile preis — gemessen im
# Review als HIGH-1 (`mcp__db__run` lieferte `"program":"psql"`), und der damalige
# Waechter blieb dabei gruen, weil er die Implementierung mass statt der Eigenschaft
# (HIGH-2). Der heutige Waechter fuettert genau solche Payloads.
set -euo pipefail
sed -i 's@^\t\treturn classNone$@\t\treturn classCommand@' internal/span/span.go
