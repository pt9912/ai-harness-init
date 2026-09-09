#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: waves bleibt aus (Entscheidung dokumentiert in harness/README.md)
#
# Entfernt alle Feldzeilen unter `planning:` (roadmap/heading/marker sowie den `closure:`-
# Unterblock mit `dir:`), laesst den Schluessel selbst und `planning` in modules: unveraendert.
# Der Block ist danach leer. Bleibt `closure:`/`dir:` stehen, ist der Block NICHT leer und die
# `waves`-Zusicherung faelschlich gruen — genau das faengt dieser Fall. Acht der zwoelf
# Zusicherungen (beide Wiring-Dateien zusammen) fangen den leeren Block laut ab
# (roadmap/heading/marker/heading-in-Roadmap/waves aus test/planning-modul-wiring.bats sowie drei
# der Existenz-Zusicherungen aus test/closure-modul-wiring.bats); vier bleiben unberuehrt gruen,
# weil sie entweder den Block gar nicht lesen (Aktivierungs-Zusicherung) oder ueber der leeren
# Menge vakuos wahr sind (die drei Negations-Zusicherungen `kein glob`/`placeholder aus`/
# `boilerplate unbesetzt`). Dieser Fall haelt die `waves`-Zusicherung: sie liest denselben leeren
# Block und faellt jetzt statt ueber der leeren Menge gruen zu bleiben.
set -euo pipefail
sed -i \
  -e '/^  roadmap: docs\/plan\/planning\/in-progress\/roadmap\.md$/d' \
  -e '/^  heading: "## Offene Wellen"$/d' \
  -e '/^  marker: "Nichts in Arbeit\."$/d' \
  -e '/^  closure:$/d' \
  -e '/^    dir: docs\/plan\/planning\/done$/d' \
  .d-check.yml
