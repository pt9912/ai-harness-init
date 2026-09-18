#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Schmuggelt den Welle-Pfad an EINER anderen Position wieder ein — als exempt-paths des
# ADR-Musters von ids statt in matrix.exempt-paths. Die Zusicherung urteilt ueber die
# ganze Datei, nicht ueber eine Zeile: jede Nennung des Pfades faengt sie, und als
# Ausnahme naehme er der Klasse welle ihre Status-Deckung.
set -euo pipefail
sed -i \
  "s|target: docs/plan/adr/, link-policy: always}|target: docs/plan/adr/, link-policy: always, exempt-paths: [\"docs/plan/planning/done/welle-*.md\"]}|" \
  internal/emit/templates/d-check.yml
