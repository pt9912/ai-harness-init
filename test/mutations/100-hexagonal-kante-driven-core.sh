#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_HexagonalEdgesMatchSkeleton
#
# Streicht die Kante `driven -> core` aus der emittierten hexagonalen Schicht-Config. Sie
# sieht wie ein Ueberschuss aus: im `a-check --print-config`-Geruest steht sie nur
# AUSKOMMENTIERT. In der gelebten Familien-Konvention wird sie real gefuehrt, weil Adapter
# auf Kern-Objekte abbilden (ADR-0010 Festlegung 1) — ohne sie ist das emittierte Skelett
# im eigenen Gate `wrong-direction`-rot, ein Ziel-Repo also nicht out-of-the-box gruen.
# Dieselbe Klasse wie die C++-Kante `adapters -> ports` (test/mutations/96).
set -euo pipefail
sed -i '/{from: driven,  to: core}/d' internal/gen/golang.go
