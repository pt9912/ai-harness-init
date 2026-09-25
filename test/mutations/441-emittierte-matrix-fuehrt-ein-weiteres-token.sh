#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_KennungsForm/token_menge
#
# Gibt der Klasse spec-straten ein token: — eine vierte Klasse traegt dann eines. Die
# Zahl der Token haengt an der Menge der Klassen, nicht am Wert eines Tokens.
set -euo pipefail
sed -i "s|direction: no-downward}|direction: no-downward, token: 'ADR-'}|" internal/emit/templates/d-check.yml
