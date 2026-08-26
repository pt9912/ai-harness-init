#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_AbdeckungStehtZuerst
# verify: test-go
#
# SCHIEBT DIE ABDECKUNG HINTER DIE KOPFZEILEN: sie steht dann in der dritten Zeile.
#
# LH-FA-10 §Leser sagt "nennt ihre Abdeckung ZUERST" — die Reihenfolge ist der Vertrag,
# nicht der Geschmack. Wer nach der ersten Zahl aufhoert zu lesen, sieht sonst den
# Nenner und haelt ihn fuer die Aussage; die Angabe, wie viel des Bestands ueberhaupt
# Zaehler trug, faellt hinten runter. Der Schaden ist lautlos: jede Zahl bleibt richtig.
set -euo pipefail
sed -i 's@^func kopf(b Bilanz) string { return abdeckungsZeile(b) + nennerZeile + summenZeile }$@func kopf(b Bilanz) string { return nennerZeile + summenZeile + abdeckungsZeile(b) }@' internal/report/report.go
