#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_SkelGoVersionOverride
#
# Der SKEL_GO_VERSION-Override wird ignoriert: der Bootstrap uebergibt fix den
# Default statt des Env-Werts an gen.Generate — der Opt-in-Knopf ist wirkungslos.
set -euo pipefail
sed -i 's/envOr("SKEL_GO_VERSION", gen.DefaultGoVersion)/gen.DefaultGoVersion/' cmd/ai-harness-init/main.go
