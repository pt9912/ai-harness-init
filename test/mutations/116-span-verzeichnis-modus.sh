#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestSpanDirIsTraversable
#
# Nimmt das Nachziehen des VERZEICHNIS-Modus weg.
#
# `MkdirAll` setzt den Modus nur beim Anlegen und unterliegt der umask — ein
# 0700-Verzeichnis aus einer frueheren Fassung bleibt unbetretbar. Genau daran ist
# `make docs-check` gescheitert ("permission denied"), und zwar erst, nachdem
# `make span-clean` den 0755-Altbestand der abgeloesten awk-Fassung weggeraeumt hatte:
# der Gate war GRUEN WEGEN ALTBESTAND. Fuer Dateien zieht `appendLine` denselben Fall
# nach; fuers Verzeichnis fehlte es bis Review-Runde 3 (F-3).
set -euo pipefail
sed -i 's@if chErr := os.Chmod(dir, 0o755); chErr != nil {@if chErr := os.Chmod(dir, 0o700); chErr != nil {@' internal/span/emit.go
