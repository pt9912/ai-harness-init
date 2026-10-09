#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# DIE ADAPTION DES d-check-FRAGMENTS STREICHT DIE KENNUNGEN AUS DEM REGISTER VON d-check NICHT
# MEHR: AdaptMK haengt den Rumpf der --print-mk-Ausgabe unveraendert an. Der Waechter liest
# das emittierte d-check.mk (Fixture der --print-mk-Ausgabe) und meldet:
#   d-check.mk: emittiert DC-FA-CLI-007, ...
# Gegenprobe: ohne die Alternative (DC|AC)-… in kennungMuster bleibt der Fall gruen — der
# Zahn bindet an genau diese Erkennung (LH-QA-01).
set -euo pipefail
sed -i 's|^\treturn \[\]byte(adopterHeader + streicheFremdeKennungen(body)), nil$|\treturn []byte(adopterHeader + body), nil|' internal/emit/emit.go
grep -q "adopterHeader + body), nil" internal/emit/emit.go
