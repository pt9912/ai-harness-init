#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestPythonLintConfig_TraegtTIDUndBanRelativeImports
#
# TID verschwindet aus select der emittierten pyproject.toml -> TID252 ist nicht ausgewaehlt, ein
# relativer Import faerbt lint nicht, und a-check extrahiert ihn nicht (ADR-0095 Festlegung 3
# und 5). Die Wirkung im Ziel faehrt Fall 696.
set -euo pipefail
sed -i 's/^select = \["E", "F", "I", "B", "TID"\]$/select = ["E", "F", "I", "B"]/' internal/gen/python.go
