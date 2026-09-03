#!/usr/bin/env bash
# files: internal/archive/stub.go
# expect: TestFormOKMeldetStehengebliebeneUeberschrift
# verify: test-go
#
# Nimmt der Stub-Form-Pruefung ihre tragende Haelfte: den Blick auf
# stehengebliebene Abschnittsueberschriften. Der Archiv-Zeiger allein bleibt
# geprueft — und genau das ist der Zustand, den die Regel benennt: ein Stub mit
# Zeiger und vollem Text waere die Archivierung, die es nicht gab.
#
# Das Rot kaeme sonst nirgends her. Ein Zip ist opak, kein Gate liest hinein,
# und ein Stub mit voller Sektion sieht im Diff aus wie ein Slice, der eben
# nicht archiviert wurde. Der Nachfolger dieses Falls in der Shell-Fassung.
set -euo pipefail
sed -i 's/^\t\tif strings.HasPrefix(zeile, "##") {$/\t\tif false \&\& strings.HasPrefix(zeile, "##") {/' internal/archive/stub.go
