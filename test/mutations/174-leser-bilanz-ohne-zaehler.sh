#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_OhneZaehlerKeineBilanz
# verify: test-go
#
# LAESST DEN LESER AUCH UEBER EINEM BESTAND OHNE VERBRAUCHS-ZAEHLER EINE BILANZ
# AUSWEISEN: TraegtZaehler meldet immer wahr.
#
# Danach stehen Rollen-Zeilen mit Nullen und eine "groesste Rolle" ueber einem Bestand,
# in dem kein Lauf je einen Zaehler trug — eine Rechnung, die nicht stattgefunden hat.
# Genau die Gate-Luege als Kennzahl, gegen die ADR-0022 Festlegung 8 den Leser statt der
# Zahl emittiert.
set -euo pipefail
sed -i 's@^func (b Bilanz) TraegtZaehler() bool { return b.MitZaehlern > 0 }$@func (b Bilanz) TraegtZaehler() bool { return true }@' internal/report/report.go
