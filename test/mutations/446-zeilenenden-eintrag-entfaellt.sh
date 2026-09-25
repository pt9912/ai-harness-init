#!/usr/bin/env bash
# files: internal/emit/zeilenenden.go
# expect: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile
#
# EIN VERZEICHNIS VERLIERT SEINE .gitattributes: die Hook-Skripte unter .claude/hooks/ haben im
# emittierten Baum keine Zeile mehr, die ihnen LF festlegt — im Klon mit core.autocrlf=true liegen
# sie mit CRLF, und ihre Shebang-Zeile lautet `bash\r`. Der Test haelt die Eigenschaft (git weist
# jeder emittierten Datei mit Interpreter-Konsument eol=lf zu), nicht die Verzeichnis-Liste der
# Emission; er faerbt rot, weil der Konsument bleibt und git ihm keinen eol-Wert mehr zuweist.
set -euo pipefail
sed -i '/dst: "\.claude\/hooks\/\.gitattributes"/d' internal/emit/zeilenenden.go
