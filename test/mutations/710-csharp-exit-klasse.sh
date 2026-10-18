#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangCsharpTagOhneMajorMinorIstExit2
#
# callExitCode fuehrt *gen.InvalidVersionError nicht mehr als Aufruf-Fehler -> add-lang endet fuer
# einen Tag ohne Major.Minor mit Exit 1 statt 2 (ADR-0096 Festlegung 2).
set -euo pipefail
sed -i 's/ [|][|] errors.As(err, &ive)/ || errors.As(err, \&ive) \&\& false/' cmd/ai-harness-init/main.go
