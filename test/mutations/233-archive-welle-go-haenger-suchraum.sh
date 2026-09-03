#!/usr/bin/env bash
# files: internal/archive/scan.go
# expect: TestHaengerFindetVerweisAusReviewReport
# verify: test-go
#
# ADR-0033 Abnahme-Kriterium 1: nimmt docs/reviews/** aus dem Suchraum, in dem
# das Unterkommando nach lebenden Verweisen sucht.
#
# Der Fall ist keine Randlage. Review-Reports verlinken einander quer ueber
# Wellen-Grenzen; ein Report, der BLEIBT und einen verlinkt, der ins Archiv geht,
# hinterlaesst nach dem Lauf einen toten Link. Das Doku-Gate befreit die
# Zeitdokumente nur von codepaths und ids — `links`/`anchors` pruefen sie wie
# jede andere Datei. Ohne den Report-Teil des Suchraums meldet die Vorschau "der
# schreibende Lauf liefe", und das Rot kaeme erst nach dem Commit.
set -euo pipefail
sed -i 's|".harness/baseline"}|".harness/baseline", "docs/reviews"}|' internal/archive/scan.go
