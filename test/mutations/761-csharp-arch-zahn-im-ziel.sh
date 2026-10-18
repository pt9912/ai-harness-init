#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: full-smoke: FEHLER — C#-Arch-Gate rot, aber nicht mit core-impurity an der Domain-Datei (rot aus falschem Grund?). Ausgabe:
# verify: full-smoke
#
# Die Domain-Schicht der C#-.a-check.yml traegt die Rolle app statt domain. Kein Go-Test liest die
# Rollen der Config; erst der reale a-check-Lauf im gebootstrappten Ziel meldet das using aus der
# Domain in einen Adapter als app-impurity statt core-impurity — die Stufe "add-lang csharp
# apps/csharphexslice --arch hexslice" in harness/tools/full-smoke.sh liest die Regel und die
# Fundstelle (LH-FA-07, ADR-0096 Festlegung 5).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^    role: domain$/    role: app/' internal/gen/csharp_hexslice.go
