#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerate_UnknownLang
#
# Die --lang-Validierung feuert nicht mehr: eine Sprache ohne Profil liefert
# keinen UnknownLangError mehr (still nichts geschrieben statt Exit 2). Die
# Validierung, die mit slice-023 vom Fetch zum Generator wanderte, waere weg.
set -euo pipefail
sed -i 's/if !ok {/if !ok \&\& false {/' internal/gen/gen.go
