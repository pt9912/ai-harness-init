#!/usr/bin/env bash
# files: internal/fetch/baseline.go
# expect: TestBaseline_SumsForm
#
# SHA256SUMS wird nach HASH statt nach PFAD sortiert. Die Datei sieht weiter
# "sortiert" aus — aber der Vollstaendigkeits-Check des Verifiers vergleicht
# Pfad-Listen (MR-007 Setzung 2).
set -euo pipefail
sed -i 's/entries\[i\]\.rel < entries\[j\]\.rel/entries[i].hash < entries[j].hash/' internal/fetch/baseline.go
