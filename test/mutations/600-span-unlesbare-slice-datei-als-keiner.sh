#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestCorrelationUnreadableSliceIsMarkedNotKnown
#
# references meldet eine unlesbare Slice-Datei als lesbar ohne Bezug: `requirement` und
# `adr` tragen dann die Kennungen der uebrigen Dateien, als waere die Liste vollstaendig,
# statt der Kennzeichnung (SPEC-012, SPEC-087). Der Anker steht repo-weit genau einmal.
set -euo pipefail
sed -i 's@return nil, nil, false@return nil, nil, true@' internal/span/emit.go
