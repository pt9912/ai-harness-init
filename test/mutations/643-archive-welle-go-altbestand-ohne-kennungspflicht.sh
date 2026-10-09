#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenAltbestandOhneKennungBrichtVorDemMoveAb
# verify: test-go
#
# DIE KENNUNGSPFLICHT DES ALTBESTANDS FAELLT: Anwenden laeuft ueber den Schluessel
# altbestand auch ohne Kennung des Aufrufers — Move, Archiv und zwei Commits ohne
# Kennung, die der commit-msg-Traeger des Repos abweist, NACHDEM der Move gestagt ist
# (ADR-0090 Festlegung 1). Der Fall meldet "Fehler = <nil>, want ErrKennungFehlt".
# Gegenprobe: ohne die errors.Is-Zusicherung im Fall bleibt er unter dieser Mutation
# noch rot an den git-Aufrufen vor dem Abbruch — beide binden dieselbe Zusage.
set -euo pipefail
sed -i 's/^\tif altbestand \&\& b\.Kennung == "" {$/\tif false \&\& b.Kennung == "" {/' internal/archive/anwenden.go
grep -q '^	if false && b.Kennung == "" {$' internal/archive/anwenden.go
