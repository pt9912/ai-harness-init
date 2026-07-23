#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CoversAllGenProfiles
#
# Der cpp-Eintrag in blockedByLang wird entfernt -> es gaebe kein blocked/cpp-Fragment, und
# die C++-Toolchain (g++/cmake/clang-tidy) liefe im Ziel ungehindert (stille Luecke). Die
# Kopplung an gen.SupportedLangs() muss rot werden (das cpp-Profil ohne BLOCKED-Fragment).
set -euo pipefail
sed -i '/"cpp": "g++ gcc/d' internal/emit/enforce.go
