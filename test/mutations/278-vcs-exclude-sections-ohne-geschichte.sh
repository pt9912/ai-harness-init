#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: exclude-sections nimmt Geschichte aus dem Kern
#
# Leert `exclude-sections` — der Kern einer angenommenen ADR zaehlt dann inklusive
# `## Geschichte`. Jede ADR dieses Repos endet mit `## Geschichte` (Fortschreibung nach
# Accept); ohne die Ausnahme faerbt jede Fortschreibung die Datei rot, statt dass nur eine
# Aenderung am eigentlichen Kern (`## Entscheidung` u. a.) es tut.
set -euo pipefail
sed -i 's/^  exclude-sections: \[Geschichte\]$/  exclude-sections: []/' .d-check.yml
