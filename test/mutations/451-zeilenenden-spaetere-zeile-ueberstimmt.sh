#!/usr/bin/env bash
# files: internal/emit/templates/enforce/gitattributes
# expect: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile
#
# EINE SPAETERE ZEILE UEBERSTIMMT DIE ZEILE: die Vorlage traegt `* text=auto eol=lf` und danach
# `*.sh eol=crlf`. Jede emittierte .gitattributes ist da und jede traegt die Zeile — git wertet die
# spaetere Zeile zuletzt und weist den Skripten eol=crlf zu, im Klon mit core.autocrlf=true wie
# ohne. Der Test fragt git nach dem Wert der Datei; die Anwesenheit einer Zeile deckt diesen Fall
# nicht.
set -euo pipefail
printf '\n*.sh eol=crlf\n' >> internal/emit/templates/enforce/gitattributes
