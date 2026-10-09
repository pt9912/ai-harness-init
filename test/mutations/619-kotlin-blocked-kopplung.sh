#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CoversAllGenProfiles
#
# Der kotlin-Eintrag in blockedByLang wird entfernt -> kein blocked/kotlin-Fragment, die
# Host-Toolchain (gradle/kotlinc/java) liefe im Ziel ungehindert (ADR-0088 Festlegung 5).
set -euo pipefail
sed -i '/"kotlin": *"gradle /d' internal/emit/enforce.go
