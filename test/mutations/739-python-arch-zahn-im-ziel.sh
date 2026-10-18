#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: full-smoke: FEHLER — Python-Arch-Gate rot, aber nicht mit core-impurity an der Domain-Datei (rot aus falschem Grund?). Ausgabe:
# verify: full-smoke
#
# Die Domain-Schicht der Python-.a-check.yml traegt die Rolle app statt domain. Kein Go-Test
# liest die Rollen der Config; erst der reale a-check-Lauf im gebootstrappten Ziel meldet den
# Import aus der Domain in einen Adapter als app-impurity statt core-impurity — die Stufe
# "add-lang python apps/pythonhexslice --arch hexslice" in harness/tools/full-smoke.sh liest die
# Regel und die Fundstelle (LH-FA-07, ADR-0095 §Fitness Function).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^    role: domain$/    role: app/' internal/gen/python_hexslice.go
