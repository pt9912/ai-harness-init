#!/usr/bin/env bash
# files: internal/emit/templates/enforce/gitattributes
# expect: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile
#
# DIE ZEILE LEGT CRLF FEST: jede emittierte .gitattributes ist da, das Verzeichnis ist gedeckt —
# und der Klon bekommt die Skripte mit CRLF, unabhaengig von core.autocrlf. Der Test liest die
# Zeile selbst, nicht die Anwesenheit der Datei.
set -euo pipefail
sed -i 's|^\* text=auto eol=lf$|* text=auto eol=crlf|' internal/emit/templates/enforce/gitattributes
