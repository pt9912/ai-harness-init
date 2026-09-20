#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestCodeGateFragmentMixed_Go
# verify: test-go
#
# NIMMT DER GEMISCHTEN GO-FASSUNG IHRE PRAEZEDENZ-ERWEITERUNG: die unscoped Ziele
# test/lint/build bekommen vom zweiten Fragment keine Voraussetzungen mehr, und der
# Kontext ist am gemischten Root nur ueber die scoped Namen erreichbar — der direkte
# Aufruf bedient nur den zuerst geschriebenen Kontext.
#
# WAS DAS MISST: die Zusage "die gemischte Fassung haengt den unscoped Zielen ihre
# Voraussetzungen an" ist ohne diesen Fall Text ohne Sensor (AGENTS.md 3.6); der
# cmd-Test haelt die WAHL der Fassung, dieser Fall ihre Form — make haengt Praezedenz-
# Listen zusammen, und genau dieser Anhang ist die Komposition.
set -euo pipefail
sed -i 's@^test: test-{{MODULE}}$@test: test-BROKEN@' internal/gen/golang.go