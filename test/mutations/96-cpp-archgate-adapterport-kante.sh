#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestArchGateConfig_CppAllowsAdapterToPorts
#
# Streicht die driven_adapters->ports_outbound-Kante aus der emittierten cpp-Schicht-
# Config. Sie sieht wie ein Copy-Paste-Ueberschuss aus (die Go-Fassung hat sie bewusst
# NICHT), ist fuer C++ aber ERFORDERLICH: ein Outbound-Adapter erfuellt seinen Port
# durch Vererbung und bindet den Port-Header damit ein. Ohne die Kante faerbt das
# Arch-Gate des generierten Skeletts rot — ein Ziel-Repo waere out-of-the-box nicht
# gruen (LH-QA-01). Die Kante ist in beiden Fassungen unter ihrem Schicht-Namen mit
# Richtungs-Segment adressiert (ports_outbound, nicht ports).
set -euo pipefail
sed -i '/{from: driven_adapters,  to: ports_outbound}/d' internal/gen/cpp.go
