#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestMandatoryFieldsAlwaysPresent
#
# HAENGT `omitempty` AN `tool` — dieselbe Mechanik wie Fall 110 (`tool_use_id`) und Fall
# 111 (`branch`), am dritten Pflichtfeld. Bei leerem Wert verschwindet die Achse aus der
# Zeile: der Leser sieht nicht das Fehlen, sondern gar nichts.
#
# WARUM ES DIESEN FALL BRAUCHT — er ist KEINE Kopie von 110. harness/conventions.md
# MR-018 schrieb bis zum 2026-07-30 die Voraussetzung der `spawned_role`-Lesart
# („`tool` bleibt Pflicht") dem Zahn 110 zu. 110 mutiert aber `tool_use_id`, 111 mutiert
# `branch`; KEIN Fall beruehrte `tool`. Streicht jemand `"tool":` aus der Pflicht-Liste
# in internal/span/span_test.go, bleibt 110 rot (ueber `tool_use_id`) und meldet weiter
# `-> TestMandatoryFieldsAlwaysPresent rot` — die tragende Zusicherung durfte lautlos
# verschwinden (Review-Befund R2-MEDIUM-1 vom 2026-07-30, dieselbe Fehlerform wie
# MEDIUM-4 eine Ebene weiter innen: der Zahn bleibt rot, die Zusage faellt weg).
# DIESER Fall bindet die Listen-Zeile: fehlt sie, bleibt er gruen — und `make mutate`
# meldet ihn als Befund.
#
# WAS ER NICHT ABDECKT, damit die Zusage nicht wieder breiter wird als der Sensor: ein
# `Agent`-Span traegt `"tool":"Agent"`, also einen NICHT-leeren Wert. `omitempty` allein
# versteckt ihn dort nicht. Die zweite Haelfte der Voraussetzung — dass ein `Agent`-Span
# an der geschriebenen Zeile als solcher erkennbar ist — ist Fall 131.
set -euo pipefail
sed -i 's@json:"tool"@json:"tool,omitempty"@' internal/span/emit.go
