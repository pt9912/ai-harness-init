#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerate_UnknownLang
#
# Die --lang-Validierung in Generate feuert nicht mehr: eine Sprache ohne Profil liefert
# nil statt eines UnknownLangError (still nichts geschrieben statt Exit 2). Die Validierung,
# die mit slice-023 vom Fetch zum Generator wanderte, waere weg. An Generates EINDEUTIGER
# Return-Zeile verankert (nicht am mehrfach vorkommenden `if !ok {`, das seit slice-037 auch
# in CodeGateFragment steht) — sonst paniced dort der Nil-Func-Call und verschoebe den Grund.
set -euo pipefail
sed -i 's/return &UnknownLangError{Lang: lang, Available: SupportedLangs()}/return nil/' internal/gen/gen.go
