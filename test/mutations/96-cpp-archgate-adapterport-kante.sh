#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestArchGateConfig_CppAllowsAdapterToPorts
#
# Streicht die adapters->ports-Kante aus der emittierten cpp-Schicht-Config. Sie sieht wie
# ein Copy-Paste-Ueberschuss aus (die Go-Fassung hat sie bewusst NICHT), ist fuer C++ aber
# ERFORDERLICH: ein Outbound-Adapter erfuellt seinen Port durch Vererbung und bindet den
# Port-Header damit ein. Ohne die Kante faerbt das Arch-Gate des generierten Skeletts rot —
# ein Ziel-Repo waere out-of-the-box nicht gruen (LH-QA-01). Bis slice-054 hing die Zusage
# allein an einem Unit-Test ohne Mutations-Fall, war also nach AGENTS.md 3.6 unbewacht.
set -euo pipefail
sed -i '/{from: adapters, to: ports}/d' internal/gen/cpp.go
