#!/usr/bin/env bash
# files: cmd/ai-harness-init/span_report.go
# expect: TestSpanReport_NichtExistierenderPfadAlsArgumentMeldetSichAlsFehlend
# verify: test-go
#
# SCHREIBT DIE BILANZ AUF DEN FALSCHEN WRITER: `spanReport` gibt den Text von
# `report.Schreibe` auf `errOut` statt auf `out` aus. Wer nur gegen internal/report
# testet, sieht diesen Fehler nie — die Wahl des Writers ist eine Eigenschaft von
# `cmd/ai-harness-init/span_report.go` allein, `internal/report` kennt gar keinen
# der beiden (slice-071 DoD (1): der CLI-Eintrittsweg braucht einen eigenen Zahn).
set -euo pipefail
sed -i 's@fmt.Fprint(out, report.Schreibe(b))@fmt.Fprint(errOut, report.Schreibe(b))@' cmd/ai-harness-init/span_report.go
