#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestArchGateConfig_OnlyLayered
#
# Die Gegenprobe zu test/mutations/102 in der anderen Richtung: die Rollen-Klassifikation
# erkennt gar keine Schicht mehr (isLayerRole liefert immer false). Dann verliert AUCH
# `hexslice` sein Arch-Gate — der Beleg, dass der Umbau von Namen auf Struktur (slice-058)
# das BESTEHENDE Layout weiter traegt und nicht nur das neue. Ohne diesen Fall waere
# "flat und hexslice bleiben unveraendert" eine Zusage ohne rot gesehenes Gegenbeispiel
# (AGENTS.md 3.6).
#
# Der sed trifft die abschliessende `return true` von isLayerRole (EINE Tab-Ebene) und
# nicht die geschachtelte in archLayered (drei Ebenen). Er laesst die Schleifenvariable
# benutzt — `if false` an ihrer Stelle waere in Go ein Compile-Fehler (declared and not
# used) und die Mutation damit rot aus falschem Grund.
set -euo pipefail
sed -i 's/^\treturn true$/\treturn false/' internal/gen/arch.go
