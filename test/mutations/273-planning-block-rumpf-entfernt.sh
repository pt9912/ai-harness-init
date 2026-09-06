#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: waves bleibt aus (Entscheidung dokumentiert in harness/README.md)
#
# Entfernt die drei Feldzeilen unter `planning:` (roadmap/heading/marker), laesst den Schluessel
# selbst und `planning` in modules: unveraendert. Der Block ist danach leer. Fuenf der sechs
# Zusicherungen fangen das laut ab (roadmap/heading/marker/heading-in-Roadmap/waves fallen); nur
# die Aktivierungs-Zusicherung ("planning ist in modules: aktiviert") bleibt unberuehrt gruen, weil
# sie den leeren `planning:`-Block gar nicht liest. Dieser Fall haelt die `waves`-Zusicherung: sie
# liest denselben leeren Block und faellt jetzt statt ueber der leeren Menge gruen zu bleiben.
set -euo pipefail
sed -i \
  -e '/^  roadmap: docs\/plan\/planning\/in-progress\/roadmap\.md$/d' \
  -e '/^  heading: "## Offene Wellen"$/d' \
  -e '/^  marker: "Nichts in Arbeit\."$/d' \
  .d-check.yml
