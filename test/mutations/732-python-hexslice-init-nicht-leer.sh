#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestPythonHexslice_InitsLeer
#
# Die Paket-Marker tragen Inhalt statt leer zu sein: ein Marker mit Import faellt ausserhalb einer
# Schicht unter keinen Glob; a-check meldet seinen Import in eine Schicht als wrong-direction,
# ein Import auf eine selbst schichtlose oder nicht aufloesende Datei bliebe ungeprueft
# (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|out\[pyHexSrc+d+"/__init__.py"\] = ""|out[pyHexSrc+d+"/__init__.py"] = "\\n"|' internal/gen/python_hexslice.go
