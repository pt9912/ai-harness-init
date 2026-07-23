#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerate_CppProfile
#
# Der cpp-Eintrag in profiles() wird entfernt -> Generate("cpp", …) liefert *UnknownLangError
# statt des Skeletts. Die zweite Sprache waere nicht mehr registriert (LH-FA-04). Der
# Profil-Waechter muss rot werden (Generate scheitert vor dem Datei-Satz).
set -euo pipefail
sed -i '/"cpp": cppProfile,/d' internal/gen/gen.go
