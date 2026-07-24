#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestRun_AddLangCppHexsliceRejected
#
# Macht archSupported(lang, arch) IMMER wahr (`if a == arch` -> `if a == arch || true`):
# die sprach×arch-Support-Pruefung (slice-045a-Review INFO-1) greift dann nicht mehr, und
# `add-lang cpp <pfad> --arch hexslice` emittiert still ein Geruestung-only-Skelett (Exit 0)
# statt Exit 2. Ohne diesen Anker faellt genau die INFO-1-Zusage lautlos. Match `if a == arch`
# ist eindeutig (nur in archSupported) und SC2016-clean.
set -euo pipefail
sed -i 's/if a == arch/if a == arch || true/' internal/gen/gen.go
