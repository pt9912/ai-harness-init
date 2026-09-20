#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestCppCodeGateFragmentMixed
# verify: test-go
#
# NIMMT DER GEMISCHTEN CPP-FASSUNG IHRE PRAEZEDENZ-ERWEITERUNG: die unscoped Ziele
# test/lint/build bekommen vom zweiten Fragment keine Voraussetzungen mehr, und der
# Kontext ist am gemischten Root nur ueber die scoped Namen erreichbar — der direkte
# Aufruf bedient nur den zuerst geschriebenen Kontext.
#
# WAS DAS MISST: dieselbe Zusage wie im Go-Fall, je Renderer einzeln — der cpp-Renderer
# haelt die C++-Fassung, und eine einseitige Aenderung an einer der beiden Vorlagen
# waere sonst still (der gemischte Root komponiert zwei Sprachen, zwei Renderer).
set -euo pipefail
sed -i 's@^test: test-{{MODULE}}$@test: test-BROKEN@' internal/gen/cpp.go