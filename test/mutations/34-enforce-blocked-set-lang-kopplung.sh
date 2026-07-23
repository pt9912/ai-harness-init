#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CoversAllGenProfiles
#
# Der go-Eintrag in blockedByLang wird entfernt -> BlockedFragmentForLang("go") ist leer.
# Dann gibt es kein blocked/go-Fragment, und die go-Toolchain liefe im Ziel ungehindert
# (stille Luecke). Die Kopplung an gen.SupportedLangs() muss rot werden (das go-Profil
# haette kein Sprach-BLOCKED-Fragment). Am Zeilen-Praefix verankert (der \n-Suffix egal).
set -euo pipefail
sed -i '/"go":.*"go gofmt/d' internal/emit/enforce.go
