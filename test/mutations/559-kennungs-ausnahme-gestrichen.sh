#!/usr/bin/env bash
# files: cmd/ai-harness-init/kennungen_test.go
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# DIE AUSNAHME-LISTE DES WAECHTERS VERLIERT EINE NUTZLAST-ZEILE: der Eintrag fuer das
# Selbstpruefungs-Fragment entfaellt, waehrend die Emission dort weiter die Kennung des
# gruenen Probe-Commits schreibt. Der Waechter haelt Fundmenge und Liste auf Gleichheit
# und meldet:
#   harness/mk/selbstpruefung.mk: emittiert LH-FA-01 — erlaubt:
# Der Fall bindet, dass die Liste namentlich ist und kein Eintrag still entfallen kann
# (LH-QA-01).
set -euo pipefail
sed -i '/^\t*"harness\/mk\/selbstpruefung\.mk": *{"LH-FA-01"},$/d' cmd/ai-harness-init/kennungen_test.go
