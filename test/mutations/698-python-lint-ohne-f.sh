#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestPythonLintConfig_TraegtTIDUndBanRelativeImports
#
# F verschwindet aus select der emittierten pyproject.toml -> F401 (unbenutzter Import) ist nicht
# ausgewaehlt, die Lint-Zeile der Fitness Function bliebe ungeprueft (ADR-0095 Festlegung 3).
# Die Wirkung im Ziel faehrt Fall 695.
set -euo pipefail
sed -i 's/"E", "F", "I", "B", "TID"/"E", "I", "B", "TID"/' internal/gen/python.go
