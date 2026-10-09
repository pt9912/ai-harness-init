#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenTraegtDieKennungDesAufrufersInBeidenCommits
# verify: test-go
#
# DER COMMIT-SUFFIX VERLIERT DIE KENNUNG DES AUFRUFERS: die Pflicht laesst den Lauf
# zu, beide Nachrichten tragen dann keine Kennung, und ein aktivierter
# commit-msg-Traeger weist Commit 1 ab, nachdem der Move gestagt ist (ADR-0090
# Festlegung 1, Fitness-Zeile 2). Der Go-Fall meldet "Commit-Nachricht endet nicht
# auf die Kennung LH-XY-42". Der Altbestand-Lauf von `make full-smoke` haengt an
# derselben Zeile; dieser Fall faehrt allein den Go-Sensor.
set -euo pipefail
sed -i 's/^\treturn ", " + b\.Kennung$/\treturn ""/' internal/archive/anwenden.go
grep -q '^	return ""$' internal/archive/anwenden.go
