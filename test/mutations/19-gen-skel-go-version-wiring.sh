#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_SkelGoVersionOverride
#
# Der SKEL_GO_VERSION-Override wird ignoriert: der Bootstrap uebergibt fix den
# Default statt des Env-Werts an gen.Generate — der Opt-in-Knopf ist wirkungslos.
set -euo pipefail
sed -i 's/envOr("SKEL_"+strings.ToUpper(lang)+"_VERSION", gen.DefaultVersion(lang))/gen.DefaultVersion(lang)/' cmd/ai-harness-init/main.go
