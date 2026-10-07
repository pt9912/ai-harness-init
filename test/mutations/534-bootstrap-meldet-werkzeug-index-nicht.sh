#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_BootstrapMeldetNeueTargets
# verify: test-go
#
# DER BOOTSTRAP VERWIRFT DEN BERICHT DES WERKZEUG-TEILS.
#
# Danach schreibt der Bootstrap neue Targets und Gates still in harness/mk/ai-harness-init.md;
# add-lang meldet weiter, darum bleibt TestRun_AddLangMeldetNeueTargets gruen. Der Test haelt
# im zweiten Bootstrap (--lang go) je neuem Gate die Zeile mit seinem Namen.
set -euo pipefail
sed -i '/"ai-harness-init: Bootstrap (Baseline/{n;s/meldeWerkzeugIndex(stdout, bericht)/_ = bericht/}' cmd/ai-harness-init/main.go
