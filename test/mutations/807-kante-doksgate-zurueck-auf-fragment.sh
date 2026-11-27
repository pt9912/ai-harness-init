#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: an der Kante haengen genau die erwarteten Checks
# verify: test-bats
#
# Zieht die Kante zurück auf das tool-generierte Fragment: record-gates hängt an
# `docs-check` (docker run, d-check.mk) statt an `docs-check-host` — der
# docker-los Pflicht-Weg liefe nicht mehr in der Kante, und die Kante über einem
# Daemon-ohne-Host würde an docker scheitern. Rot faerbt
# test/gate-nachweis-kante.bats (die Erwartungsliste — docs-check-host, seit
# slice-labor-gates-host-rezepte).
set -euo pipefail
sed -i '/^record-gates:/ s/docs-check-host /docs-check /' Makefile
