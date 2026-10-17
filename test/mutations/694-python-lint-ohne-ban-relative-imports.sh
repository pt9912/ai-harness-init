#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestPythonLintConfig_TraegtTIDUndBanRelativeImports
#
# ban-relative-imports = "all" verschwindet aus der emittierten pyproject.toml -> TID252 gilt
# nur in der Voreinstellung "parents", ein Geschwister-Import `from . import x` faerbt lint
# nicht (ADR-0095 Festlegung 3). Die Wirkung im Ziel faehrt Fall 696.
set -euo pipefail
sed -i '/^ban-relative-imports = "all"$/d' internal/gen/python.go
