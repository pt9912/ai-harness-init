#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_EdgesAcyclic
#
# Traegt die Kante `ports -> core` in die hexagonale Config nach — die eine Kante, die
# beim Lesen am plausibelsten aussieht (die Ports gehoeren doch zum Kern) und die
# ADR-0010 aus genau einem Grund NICHT fuehrt: zusammen mit `core -> ports` ist sie in
# EINER Kern-Schicht ein Import-Zyklus. Das Gate bliebe gruen — es prueft Richtungen,
# nicht Zyklenfreiheit —, aber ein Adopter, der beide Richtungen wirklich nutzt, bekaeme
# ein Skelett, das die Zielsprache nicht uebersetzt.
set -euo pipefail
sed -i 's|  - {from: core,    to: ports}|  - {from: core,    to: ports}\n  - {from: ports,   to: core}|' internal/gen/golang.go
