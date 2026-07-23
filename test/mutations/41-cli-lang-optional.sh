#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_SprachlosKeinExit2
#
# hasLang wird IMMER true (slice-035): dann laeuft der sprachlose Init (--lang leer) durch
# gen.Generate("") -> UnknownLangError -> Exit 2, statt sprach-agnostisch weiterzumachen.
# Das ist das alte --lang-Refuse durch die Hintertuer. Der Test erwartet Exit 1 (Phase-3-
# Kollision), bekommt Exit 2 -> rot. Belegt, dass --lang wirklich optional ist (LH-FA-01).
set -euo pipefail
sed -i 's/hasLang := lang != ""/hasLang := true/' cmd/ai-harness-init/main.go
