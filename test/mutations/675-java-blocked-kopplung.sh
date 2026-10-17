#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CoversAllGenProfiles
#
# Der java-Eintrag in blockedByLang wird entfernt -> kein blocked/java-Fragment, die
# Host-Toolchain (gradle/javac/checkstyle/mvn) liefe im Ziel ungehindert (ADR-0094 Festlegung 5).
set -euo pipefail
sed -i '/"java": *"gradle /d' internal/emit/enforce.go
