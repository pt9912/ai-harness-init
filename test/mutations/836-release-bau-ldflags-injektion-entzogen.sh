#!/usr/bin/env bash
# files: Makefile
# expect: das Binary des Host-Baus traegt TRAEGER_VERSION als Fassung
# verify: test-bats
#
# Zieht die Fassungs-Injektion aus dem Host-Release-Rezept (a-2, ADR-0115
# Festlegung 6): der ldflags-Operand faellt, `$(if $(TRAEGER_VERSION))` bleibt
# syntaktisch gueltig, und der Bau injiziert nicht mehr — das Binary meldet auf
# `--version` den Fehlt-Fall, obwohl der Tag uebergeben wurde. Der Waechter baut
# mit TRAEGER_VERSION und verlangt den Tag auf stdout (ADR-0063 Festlegung 1).
# MR-071: der Anker liegt im Rezept-Block release-artifacts-host, nicht bei
# `host-bin` — dessen Form bleibt unberuehrt.
set -euo pipefail
sed -i "/^release-artifacts-host:/,/^\$/{s/, -X main\.fassung=\$(TRAEGER_VERSION)//}" Makefile
