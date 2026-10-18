#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestGenerate_PythonHexsliceProfile_FileSet
#
# Dem Verzeichnis der Domain-Beispielschicht fehlt seine __init__.py: der Datei-Satz des
# Skeletts weicht von der ausgeschriebenen Erwartung ab (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|\[\]string{"hexagon", "hexagon/domain", "hexagon/domain/example"}|[]string{"hexagon", "hexagon/domain"}|' internal/gen/python_hexslice.go
