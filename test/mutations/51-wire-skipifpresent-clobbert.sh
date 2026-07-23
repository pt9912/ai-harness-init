#!/usr/bin/env bash
# files: internal/wire/wire.go
# expect: TestPlace_SkipIfPresent
#
# Der skip-if-present-Zweig von wire.Place wird gebrochen (das einzige `continue` -> break,
# faellt auf den Write durch): dann clobbert ein Re-Lauf adopter-gewachsenen Skelett-Code
# (slice-038). Der skip-if-present-Waechter (Skelett-Code nie ueberschreiben) muss rot werden.
set -euo pipefail
sed -i 's/continue/break/' internal/wire/wire.go
