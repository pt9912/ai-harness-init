#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: genau eine head-allow-Zeile (kein stilles YAML-Duplikat)
#
# Dupliziert die `head-allow`-Zeile im `vcs:`-Block mit einer zweiten, dauerhaft gruenen Fassung
# (matcht jede Statuszeile). YAML nimmt bei einem doppelten Mapping-Schluessel stillschweigend
# den letzten Wert — ein Reviewer, der die erste (korrekte) Zeile liest, sieht nicht, dass eine
# zweite sie unbemerkt ueberschreibt.
set -euo pipefail
sed -i "/^  head-allow: /a\\  head-allow: '.*'" .d-check.yml
