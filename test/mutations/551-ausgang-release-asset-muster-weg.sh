#!/usr/bin/env bash
# files: harness/tools/full-smoke-ausgang.sh
# expect: 404 auf das Release-Asset des gepinnten Tags -> LEITUNG mit Klasse
# verify: test-bats
#
# NIMMT DEM EINORDNER DAS MUSTER (5): die curl-Antwort auf einen nicht mit 2xx
# beantworteten Abruf eines Release-Assets faellt dann in den BAUM-Ausgang — die Lage
# der CI-Jobs am Tag-Commit, an denen das Muster gemessen ist (LH-QA-01, ADR-0058).
# Der Fall in test/full-smoke-ausgang.bats faehrt den zitierten Ausschnitt eines
# dieser Jobs.
set -euo pipefail
sed -i '/^\t.curl: \\(22\\) The requested URL returned error: /d' harness/tools/full-smoke-ausgang.sh
