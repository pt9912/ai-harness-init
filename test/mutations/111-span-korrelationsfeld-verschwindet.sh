#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation
#
# Haengt `omitempty` an `branch`. `branch` ist Pflichtfeld der Draht-Form und traegt ohne
# ableitbare Referenz die Kennzeichnung `nicht bekannt: .git/HEAD` (SPEC-087, SPEC-014):
# `gitRef()` liefert nie einen leeren String, `omitempty` kann den Wert also nicht mehr
# verschwinden lassen — den Zahn traegt der Satz der Feldliste, der `branch` als Feld
# mit Kennzeichnung nennt, nicht `TestMandatoryFieldsAlwaysPresent`.
set -euo pipefail
sed -i 's@json:"branch"@json:"branch,omitempty"@' internal/span/emit.go
