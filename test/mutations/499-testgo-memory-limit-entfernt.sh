#!/usr/bin/env bash
# files: Makefile
# expect: makefile: der Image-Testlauf traegt einen Speicher-Deckel (--memory)
#
# Entfernt `--memory $(TEST_MEMORY)` aus dem docker-run-Aufruf des test-go-image-
# Rezepts (Makefile). Der Speicher-Deckel haengt an keiner Verhaltens-Zusage
# des geprueften Codes: `make test-go-image` selbst liefe ohne ihn unveraendert
# durch, weil kein Test der Go-Stufe an der Flag-Zeile haengt. Die bats-Assertion
# haelt die Flag-Zeile textuell fest und faerbt bei ihrer Abwesenheit rot. Seit
# slice-labor-gates-host-rezepte traegt der Deckel allein den opt-in Image-Weg
# (ADR-0109) — der Anker versieht deshalb die IMAGE-Zeile, wie der Wächter.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, wie test/mutations/264).
set -euo pipefail
sed -i "/^test-go-image:/,/^\$/ s/ --memory \$(TEST_MEMORY)//" Makefile
