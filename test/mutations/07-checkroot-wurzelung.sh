#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_FalscheWurzelung
#
# Die zweite Ebene der Wurzel-Pruefung faellt weg. Eine NACHFAHREN-Wurzelung
# (z. B. templates/spec/) traegt in-scope-Templates an ihrer Wurzel und kaeme
# damit durch — der Emit schriebe lastenheft.md in den Ziel-ROOT statt nach
# spec/ (Review-Befund slice-026 F-3, Erkennungs-Regression).
set -euo pipefail
sed -i 's/case deeper == 0:/case false:/' internal/emit/templates.go
