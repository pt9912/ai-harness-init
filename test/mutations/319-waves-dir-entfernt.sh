#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: waves.dir zeigt auf docs/plan/planning
#
# Entfernt die Zeile `dir: docs/plan/planning` unter `waves:` — laut Werkzeug-Handbuch ist `dir`
# der Aktivierungs-Schalter der Faehigkeit: "leer ⇒ inert (kein Wellendokument wird geoeffnet)".
# `docs-check` selbst faellt darauf still zurueck auf "0 Befund(e)" statt auf einen leeren
# Pruefbereich zu melden (LH-QA-01). `mode:` bleibt im Block stehen, darum haelt NICHT der
# Nichtleer-Test die Mutation, sondern die Feld-Zusicherung — dieser Waechter haelt die
# Aktivierung ohne einen Docker-Lauf.
set -euo pipefail
sed -i '/^    dir: docs\/plan\/planning$/d' .d-check.yml
