#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: jeder Wortlaut-Marker trifft seine Vorlage am gepinnten Stand genau einmal
# verify: test-bats
#
# VERFAELSCHT EINEN WORTLAUT-MARKER: carveoutsDoneRefOld nennt "Kurs-Regelwerk" statt
# "Baseline-Regelwerk". Die Vorlage docs/plan/planning/README.template.md des gepinnten
# Kurs-Stands traegt den Wortlaut nicht, strings.ReplaceAll wird ein stiller No-op. Der
# Waechter liest Marker und Vorlage am vendored Baum und meldet:
#   carveoutsDoneRefOld: 0 Treffer in docs/plan/planning/README.template.md (<tag>) — erwartet genau 1
# Der Fall bindet die Treffer-Pruefung je Marker (LH-FA-02).
set -euo pipefail
sed -i 's/^\(const carveoutsDoneRefOld = .*\)(Baseline-Regelwerk"$/\1(Kurs-Regelwerk"/' internal/emit/templates.go
