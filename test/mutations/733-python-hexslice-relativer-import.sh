#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestPythonHexslice_NurAbsoluteImporte
#
# Der Handler importiert die Domain relativ. a-check extrahiert einen relativen Import nicht
# (Hinweis, Exit 0): die Kante app -> domain entginge dem Arch-Gate (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|^from app\.hexagon\.domain\.example\.greeting import new_greeting$|from ...domain.example.greeting import new_greeting|' internal/gen/python_hexslice.go
