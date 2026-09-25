#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Schaltet die Link-Pflicht des ADR-Musters von ids ab: eine blanke ADR-Kennung ist dann kein
# Befund mehr. Der Herkunfts-Kommentar der Vorlage nennt link-policy: always ebenfalls; die
# Zusicherung liest darum die Zeile des Musters im ids:-Block, nicht die ganze Datei.
set -euo pipefail
sed -i "s|target: docs/plan/adr/, link-policy: always}|target: docs/plan/adr/, link-policy: never}|" internal/emit/templates/d-check.yml
