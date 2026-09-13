#!/usr/bin/env bash
# files: .d-check.yml
# expect: jede Makefile-Regel ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets
#
# Entfernt den Eintrag `help` aus `exempt-targets`. Das Rezept `help` traegt weiterhin kein
# `make help` in einer Tabellenzeile des Sensors-Abschnitts von `harness/README.md` — die kuratierte Liste deckt den Bestand danach
# nicht mehr vollstaendig, und ein `docs-check`-Lauf faende `help` als `gate-undocumented`.
set -euo pipefail
sed -i '/^    - help$/d' .d-check.yml
