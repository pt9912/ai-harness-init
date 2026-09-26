#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenUnterReviewsSchreibtNurDieLinkForm
# verify: test-go
#
# NIMMT DEM LINK-NACHZUG UNTER docs/reviews/ SEIN WELLE-SEGMENT: ErsetzePraefixLink
# zaehlt die Links danach weiter, schreibt aber dasselbe Ziel zurueck. Die vier
# Nicht-Link-Formen bleiben stehen, der Link zeigt nach dem Umzug auf das
# Verzeichnis, das die Datei verlassen hat, und `make docs-check` faerbt an ihm
# `target-missing` (ADR-0070, die Politik, die die Entscheidung als tote Links
# verwirft).
#
# WAS DAS MISST: derselbe Fall wie in 467 faerbt rot, weil er in EINER Datei den
# Link UND die vier anderen Formen fuehrt — die Haelfte, die bei der Mutation
# 467 rot wird, und die, die hier rot wird.
#
# Der Anker steht genau einmal in refs.go, als Schreib-Zeile in ErsetzePraefixLink
# (grep -cF 'b.WriteString(doneName + "/" + welleID + "/" + base)' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~b.WriteString(doneName + "/" + welleID + "/" + base)~b.WriteString(doneName + "/" + base)~' internal/archive/refs.go
