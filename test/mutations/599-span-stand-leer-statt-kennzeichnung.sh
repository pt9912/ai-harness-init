#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestUnresolvableGitRefIsMarkedNotKnown
#
# gitRef laesst ein nicht ableitbares `commit` leer statt der Kennzeichnung
# `nicht bekannt: .git/HEAD` (SPEC-056, SPEC-087). Der Anker steht repo-weit genau einmal.
set -euo pipefail
sed -i 's@commit = NotKnown(SourceGitHead)@commit = ""@' internal/span/emit.go
