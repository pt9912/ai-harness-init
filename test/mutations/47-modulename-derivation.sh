#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestModuleName
#
# Die Subdir-Ableitung von ModuleName wird neutralisiert (Pfad -> lang): dann traegt jedes
# Modul den Sprach-Namen statt des <pfad>-abgeleiteten (apps/api -> apps-api), zwei Module
# gleicher Sprache kollidierten auf demselben Fragment/Target. Der Namens-Waechter muss rot werden.
set -euo pipefail
sed -i 's#return strings.ReplaceAll(clean, "/", "-")#return lang#' internal/gen/gen.go
