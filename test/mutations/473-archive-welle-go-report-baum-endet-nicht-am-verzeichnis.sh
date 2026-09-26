#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenUnterReviewsGiltNurFuerDasVerzeichnisNichtFuerSeinenPraefix
# verify: test-go
#
# NIMMT DEM REPORT-BAUM SEINE VERZEICHNISGRENZE: imReportBaum prueft danach nur
# noch, ob der Pfad mit "docs/reviews" beginnt, nicht mehr mit "docs/reviews/".
# Ein Geschwister-Verzeichnis dieses Praefixes (docs/reviews-alt/) geht dann in die
# Link-Form, und ein Pfad dort bleibt trotz Nachzug auf dem alten Ort stehen.
#
# WAS DAS MISST: der Fall legt denselben Inhalt (Link und Span) in
# docs/reviews/ und in docs/reviews-alt/ ab und liest beide Dateien ganz. Der
# Baum darunter bekommt nur den Link, der Nachbar jede Form.
#
# Der Anker steht genau einmal in refs.go, als Rumpf von imReportBaum
# (grep -cF 'reviewsDir+"/")' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~reviewsDir+"/")~reviewsDir)~' internal/archive/refs.go
