#!/usr/bin/env bash
# files: internal/emit/templates/enforce/gitattributes
# expect: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile
#
# DIE ZEILE LEGT CRLF FEST: jede emittierte .gitattributes ist da und jedes Verzeichnis ist
# gedeckt — der Klon bekommt die Skripte mit CRLF, unabhaengig von core.autocrlf. Der Test fragt
# git nach dem eol-Wert der Datei, nicht nach der Anwesenheit der Datei.
set -euo pipefail
sed -i 's|^\* text=auto eol=lf$|* text=auto eol=crlf|' internal/emit/templates/enforce/gitattributes
