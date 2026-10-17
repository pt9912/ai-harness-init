#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CoversAllGenProfiles
#
# Der python-Eintrag in blockedByLang wird entfernt -> kein blocked/python-Fragment, die
# Host-Toolchain (python/pytest/ruff/mypy) liefe im Ziel ungehindert (ADR-0095 Festlegung 6).
set -euo pipefail
sed -i '/"python": *"python python3 /d' internal/emit/enforce.go
