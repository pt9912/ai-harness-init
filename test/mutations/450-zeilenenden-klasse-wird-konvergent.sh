#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet
#
# EIN skip-if-present-PFAD WIRD KONVERGENT: `harness/mk/.gitattributes` liegt im Namensraum, den der
# Adopter mitfuehrt (vorgaben.mk, eigene Fragmente). Die Klasse skip-if-present laesst dort eine
# liegende Datei stehen und meldet sie; die Klasse konvergent schreibt sie mit dem Inhalt des
# Werkzeugs neu. Der Test haelt die Klasse je Pfad gegen die Festlegung der ADR.
set -euo pipefail
sed -i 's|dst: "harness/mk/.gitattributes", mode: 0o644, class: SkipIfPresent|dst: "harness/mk/.gitattributes", mode: 0o644, class: Konvergent|' internal/emit/zeilenenden.go
