#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_SkipIfPresent
#
# Der skip-if-present-Zweig von BlockedFragment wird gebrochen (return nil -> break): dann
# clobbert ein zweiter add-lang derselben Sprache das vorhandene blocked/<lang> statt es zu
# teilen (Mono-Repo-Kern, slice-037). Der skip-if-present-Waechter (kein Clobber) muss rot werden.
set -euo pipefail
sed -i 's#return nil // skip-if-present.*#break#' internal/emit/enforce.go
