#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau
# verify: test-go
#
# Lauf und Vorschau lesen dieselbe Einsammel-Menge. Die Mutation laesst den Lauf
# nur die erste Haelfte der eingesammelten Slices bewegen: die Zahl 'wellenlos'
# der Vorschau und die Stubs unter done/altbestand/ gehen auseinander.
set -euo pipefail
sed -i 's/^\tfor _, p := range append(b\.Slices(), b\.Plaene\.\.\.) {$/\tfor _, p := range append(b.Slices()[:len(b.Slices())\/2], b.Plaene...) {/' internal/archive/anwenden.go
