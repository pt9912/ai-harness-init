#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Der erste inScope-Zweig feuert nie mehr. Damit fallen .d-check.yml, Makefile
# und die Set-Index-README durch bis zum default: true — das Ziel bekommt sie,
# LH-FA-02 gebrochen (Befund 022b F-1).
set -euo pipefail
sed -i 's/case !strings\.HasSuffix(rel, "\.template\.md"):/case false:/' internal/emit/templates.go
