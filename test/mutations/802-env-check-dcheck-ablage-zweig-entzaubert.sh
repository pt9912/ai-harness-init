#!/usr/bin/env bash
# files: harness/tools/environment-check.sh
# expect: d-check trägt Anwesenheit auch an der fetched Ablage
# verify: test-bats
#
# Entzaubert die ausdrückliche Erweiterung der d-check-Anwesenheit an der
# fetched Ablage (slice-binraire-ziehen-ohne-docker: probe_dcheck_ablage, Inventar-
# Zeile d-check Grund-Spalte): `[ -x "$p" ]` wird zu `[ -f "$p.tmp-nie" ]` — die
# Ablage traegt dann nie, ein gelegter Binary faerbt trotzdem "Ist: fehlt" (der
# Inventar-Anschluss haengt still ab). Rot faerbt test/environment-check.bats,
# Test "environment-check: d-check trägt Anwesenheit auch an der fetched Ablage
# (PATH sieht es nicht)". Rot gesehene Gegenprobe: Hand-Mutation an der realen
# Datei, Test 9 fiel.
set -euo pipefail
sed -i 's/\[ -x "$p" \]/[ -f "$p.tmp-nie" ]/' harness/tools/environment-check.sh
