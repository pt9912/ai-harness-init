#!/usr/bin/env bash
# files: internal/emit/templates/enforce/gitattributes
# expect: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile
#
# DIE ZEILE ERFASST NUR `*.sh`: die Skripte liegen mit LF, die Wortlisten unter blocked/<sprache>
# und der git-eigene Traeger `commit-msg` (beide ohne Endung) mit CRLF — der Mischzustand, in dem
# der Command-Guard sein letztes Listenwort verliert, ohne eine Meldung zu geben. Der Test verlangt
# `*` als Muster.
set -euo pipefail
sed -i 's|^\* text=auto eol=lf$|*.sh text=auto eol=lf|' internal/emit/templates/enforce/gitattributes
