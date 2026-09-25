#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet
#
# EIN skip-if-present-PFAD WIRD KONVERGENT: `harness/mk/.gitattributes` liegt im Namensraum, den der
# Adopter mitfuehrt (vorgaben.mk, eigene Fragmente); der Lauf ueberschriebe dort eine Datei mit
# seinem Inhalt, statt sie stehen zu lassen und zu melden.
set -euo pipefail
sed -i 's|dst: "harness/mk/.gitattributes", mode: 0o644, class: SkipIfPresent|dst: "harness/mk/.gitattributes", mode: 0o644, class: Konvergent|' internal/emit/zeilenenden.go
