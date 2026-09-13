#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: heading zeigt auf den Abschnitt 'Offene Wellen', nicht auf den Modul-Default
#
# Entfernt alle Feldzeilen unter `planning:` (roadmap/heading/marker sowie den `closure:`-
# Unterblock mit `dir:`), laesst den Schluessel selbst, den unveraenderten `waves:`-Unterblock
# und `planning` in modules: stehen. Der Block ist danach NICHT leer — `waves:` (dir + mode)
# ueberlebt unberuehrt, weil der `dir:`-Regex nur auf den ABGELOESTEN Wert `docs/plan/planning/done`
# (closure) passt, nicht auf `docs/plan/planning` (waves). Gemessen (bats im gepinnten Bild, drei
# Wiring-Dateien: test/planning-modul-wiring.bats, test/closure-modul-wiring.bats,
# test/waves-modul-wiring.bats, zusammen 15 Zusicherungen): **sieben** fallen —
# roadmap/heading/marker/"heading existiert in der Roadmap" aus test/planning-modul-wiring.bats
# sowie die drei Existenz-/Wert-Zusicherungen aus test/closure-modul-wiring.bats. **Acht** bleiben
# gruen: die Aktivierungs-Zusicherung aus test/planning-modul-wiring.bats (liest nur `modules:`,
# nicht den Block-Rumpf), drei Negations-Zusicherungen aus test/closure-modul-wiring.bats
# (`kein glob`/`placeholder aus`/`boilerplate unbesetzt`, vakuos wahr ueber dem leeren
# `closure:`-Rumpf) und alle vier Zusicherungen aus test/waves-modul-wiring.bats — `waves` liest
# einen eigenen, von diesem Fall unberuehrten Unterblock und bleibt darum unabhaengig von diesem
# Fall gruen. Dieser Fall haelt die vier top-level `planning:`-Felder (roadmap/heading/marker/
# closure.dir); die Existenz und Bindung von `waves` haelt test/mutations/319-321.
set -euo pipefail
sed -i \
  -e '/^  roadmap: docs\/plan\/planning\/in-progress\/roadmap\.md$/d' \
  -e '/^  heading: "## Offene Wellen"$/d' \
  -e '/^  marker: "Nichts in Arbeit\."$/d' \
  -e '/^  closure:$/d' \
  -e '/^    dir: docs\/plan\/planning\/done$/d' \
  .d-check.yml
