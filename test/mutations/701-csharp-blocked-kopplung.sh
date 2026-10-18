#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CoversAllGenProfiles
#
# Der csharp-Eintrag in blockedByLang wird entfernt -> kein blocked/csharp-Fragment, die
# Host-Toolchain (dotnet) liefe im Ziel ungehindert (ADR-0096 Festlegung 6).
set -euo pipefail
sed -i '/"csharp": *"dotnet msbuild /d' internal/emit/enforce.go
