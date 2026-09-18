#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Schmuggelt den Welle-Pfad an einer ANDEREN Position wieder ein — als exempt-paths des
# ADR-Musters von ids statt in matrix.exempt-paths. Die Zusicherung urteilt ueber die
# ganze Datei, nicht ueber eine Zeile: an keiner Position darf der Pfad die
# Status-Deckung der Klasse welle zuruecknehmen.
set -euo pipefail
sed -i \
  "s|link-policy: always}|link-policy: always, exempt-paths: [\"docs/plan/planning/done/welle-*.md\"]}|" \
  internal/emit/templates/d-check.yml
