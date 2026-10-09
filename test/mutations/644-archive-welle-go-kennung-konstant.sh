#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenTraegtDieKennungDesAufrufersInBeidenCommits
# verify: test-go
#
# DER COMMIT-SUFFIX NIMMT WIEDER EINE KENNUNG DES WERKZEUGS statt der des Aufrufers:
# beide Nachrichten enden auf ", ADR-0041)" — eine Kennung, die im Ziel nicht
# aufloest (ADR-0090 Festlegung 1). Der Fall meldet "Commit-Nachricht endet nicht
# auf die Kennung LH-XY-42". Ebenso rot: TestTraegerMeldungenTragenKeineKennung.
set -euo pipefail
sed -i 's/^\treturn ", " + b\.Kennung$/\treturn ", ADR-0041"/' internal/archive/anwenden.go
grep -q '^	return ", ADR-0041"$' internal/archive/anwenden.go
