#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# DIE ADAPTION DES a-check-FRAGMENTS STREICHT DIE SLICE-KENNUNG VON a-check NICHT MEHR:
# AdaptArchMK haengt den Rumpf unveraendert an. Der Waechter liest das emittierte a-check.mk
# (archMKFixture traegt die Zeile "# die andere (slice-082).") und meldet:
#   a-check.mk: emittiert slice-082
# Gegenprobe: ohne die Alternative slice-[0-9]+ in kennungMuster bleibt der Fall gruen
# (LH-QA-01).
set -euo pipefail
sed -i 's|^\treturn \[\]byte(archAdopterHeader + streicheFremdeKennungen(body)), nil$|\treturn []byte(archAdopterHeader + body), nil|' internal/emit/archgate.go
grep -q "archAdopterHeader + body), nil" internal/emit/archgate.go
