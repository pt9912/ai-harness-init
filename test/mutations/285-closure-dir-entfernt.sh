#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure ist ueber dir aktiviert
#
# Entfernt die Zeile `dir: docs/plan/planning/done` unter `closure:` — laut Werkzeug-Handbuch ist
# `dir` der Aktivierungs-Schalter der Faehigkeit: "leer ⇒ inert (keine Slice-Datei wird geoeffnet)".
# `docs-check` selbst faellt darauf still zurueck auf "0 Befund(e)" statt auf einen leeren
# Pruefbereich zu melden (LH-QA-01) — dieser Waechter haelt die Aktivierung ohne einen Docker-Lauf.
set -euo pipefail
sed -i '/^    dir: docs\/plan\/planning\/done$/d' .d-check.yml
