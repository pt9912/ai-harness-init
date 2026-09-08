#!/usr/bin/env bash
# files: cmd/ai-harness-init/vendor_baseline.go
# expect: TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff
#
# Schaltet die Sperre gegen einen ANDEREN Tag unter baselineDir(root) aus:
# ohne sie faehrt ein Lauf mit abweichendem <tag> bis zum Netz-Fetch durch und
# legt ein zweites Verzeichnis neben ein vorhandenes, statt vor jedem Zugriff
# abzubrechen — MR-007 Setzung 4 verlangt genau ein <tag>-Verzeichnis. Der
# Fall haelt genau diesen Pfad: der Asset-Fetch bleibt aus, stdout bleibt
# leer und der fremde Tag bleibt unveraendert nur, wenn die Sperre greift.
set -euo pipefail
sed -i 's/if fremd != "" {/if false \&\& fremd != "" {/' cmd/ai-harness-init/vendor_baseline.go
