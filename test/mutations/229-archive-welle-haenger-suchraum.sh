#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: Haenger-Suchraum: docs/reviews ist NICHT ausgenommen, die vendored Baseline schon
#
# Nimmt die Haenger-Vorpruefung genau das Verzeichnis aus, gegen das sie
# schuetzt: Review-Reports verlinken einander quer ueber Wellen-Grenzen, und
# `links`/`anchors` pruefen docs/reviews/** wie jede andere Datei. Der Wechsel
# waere still — der Lauf meldete "ok", setzte zwei Commits und liesse
# `make docs-check` an einem Ziel rot, das der fail-closed-Ausgang haette
# nennen sollen.
set -euo pipefail
sed -i "s#printf '%s\\\\n' ':!.harness/baseline'#printf '%s\\\\n' ':!.harness/baseline' ':!docs/reviews'#" harness/tools/archive-welle.sh
