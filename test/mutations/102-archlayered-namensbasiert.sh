#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestArchGateConfig_CoversEveryLayeredCombo
#
# Setzt die Geschichtet-Erkennung auf die NAMENS-Fassung zurueck, die bis slice-058 galt
# (`r == roleDomain` statt der strukturellen Bedingung). Fuer hexslice aendert das nichts —
# und genau das ist die Falle: `hexagonal` traegt keine Rolle namens `domain`, gilt damit
# als flach und bekommt KEIN Arch-Gate, waehrend alles gruen bleibt. Das ist der Befund,
# den der Plan-Review als HIGH gefunden hat (ADR-0010 Folgepflicht 1, LH-QA-01); der
# Waechter darf ihn nur fangen, wenn er `geschichtet` aus dem gerenderten BAUM ableitet
# und nicht dieselbe Funktion befragt, die er bewacht.
set -euo pipefail
sed -i 's/if isLayerRole(r) {/if r == roleDomain {/' internal/gen/arch.go
