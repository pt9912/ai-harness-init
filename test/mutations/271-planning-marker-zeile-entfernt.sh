#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: marker traegt den Ruhe-Marker dieses Repos, nicht den Modul-Default
#
# Loescht die `marker:`-Zeile aus dem planning:-Block. `docs-check` faellt darauf NICHT rot: ohne
# eigenes Feld greift der Modul-Default "Keine aktive Welle", ein Text, der in
# docs/plan/planning/in-progress/roadmap.md nirgends steht und die Invariante darum ueber diesem
# Baum ebenso erfuellt wie der repo-eigene Marker — 0 Befund(e), Exit 0. Dieser Waechter haelt die
# Kopplung an den repo-eigenen Ruhe-Marker, wo docs-check selbst keine Aussage macht.
set -euo pipefail
sed -i '/^  marker: "Nichts in Arbeit\."$/d' .d-check.yml
