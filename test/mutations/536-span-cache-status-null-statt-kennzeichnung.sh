#!/usr/bin/env bash
# files: internal/span/notknown.go
# expect: TestCacheStatusIsMarkedNotKnown
#
# SCHREIBT `0` STATT DER KENNZEICHNUNG. Ein Cache-Zaehler ohne Wert steht dann als
# `"cache_creation_input_tokens":0` in der Zeile — eine Messung, die nie stattfand,
# und genau die Form, die SPEC-087 ausschliesst. Die Stelle ist die eine, an der beide
# Cache-Zaehler ihre Draht-Form bekommen (CacheCount.MarshalJSON).
set -euo pipefail
sed -i 's@^\treturn json.Marshal(NotKnown(SourceUsage))$@\treturn []byte("0"), nil@' internal/span/notknown.go
