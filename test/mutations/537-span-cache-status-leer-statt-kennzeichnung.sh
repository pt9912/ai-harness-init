#!/usr/bin/env bash
# files: internal/span/notknown.go
# expect: TestCacheStatusIsMarkedNotKnown
#
# SCHREIBT `""` STATT DER KENNZEICHNUNG. Das Feld steht da, sagt aber nicht, dass der
# Wert nicht bekannt ist, und nennt die Quelle nicht (SPEC-087).
set -euo pipefail
sed -i 's@^\treturn json.Marshal(NotKnown(SourceUsage))$@\treturn json.Marshal("")@' internal/span/notknown.go
