#!/usr/bin/env bash
# files: Makefile
# expect: der Default-Pfad reicht KEINE Zielplattform durch
#
# Laesst den DEFAULT-Pfad eine Zielplattform durchreichen. Damit haengt das bisherige
# Artefakt (und damit artifact, smoke, full-smoke) an einem anderen Bau als zuvor —
# die Byte-Identitaet, die dieser Slice ausdruecklich zusagt, faellt still.
set -euo pipefail
sed -i 's|--target build -t ai-harness-init:build \.|--build-arg TARGET_OS=linux --target build -t ai-harness-init:build .|' Makefile
