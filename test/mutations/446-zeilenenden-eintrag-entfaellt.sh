#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile
#
# EIN VERZEICHNIS VERLIERT SEINE .gitattributes: die Hook-Skripte unter .claude/hooks/ tragen
# im emittierten Baum keine Zeile mehr, die ihnen LF festlegt — im Klon mit core.autocrlf=true
# lagen sie mit CRLF, und ihre Shebang-Zeile lautete `bash\r`. Der Test haelt die Eigenschaft
# (jede emittierte Datei mit Interpreter-Konsument liegt unter einer Zeile), nicht die
# Verzeichnis-Liste der Emission; er faerbt rot, weil der Konsument bleibt und sein Vorfahr
# keine Zeile mehr traegt.
set -euo pipefail
sed -i '/dst: "\.claude\/hooks\/\.gitattributes"/d' internal/emit/zeilenenden.go
