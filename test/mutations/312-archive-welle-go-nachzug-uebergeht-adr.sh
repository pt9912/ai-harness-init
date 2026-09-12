#!/usr/bin/env bash
# files: internal/archive/scan.go
# expect: TestVerweisFundUndNachziehenUebergehenAcceptedADR
# verify: test-go
#
# ADR-0042 Festlegung 2: nimmt `docs/plan/adr` wieder aus der
# Nachzug-Ausnahmeliste heraus. VerweisFund und Nachziehen wuerden damit
# wieder in eine Accepted-ADR schreiben, genau wie vor diesem Ausschluss.
#
# Haenger ist NICHT Ziel dieser Mutation — AusgenommenePfade() bleibt
# unveraendert, TestHaengerFindetVerweisAusReviewReport und
# test/mutations/233-archive-welle-go-haenger-suchraum.sh bleiben unberuehrt.
set -euo pipefail
sed -i 's/return append(AusgenommenePfade(), "docs\/plan\/adr")/return AusgenommenePfade()/' internal/archive/scan.go
