#!/usr/bin/env bash
# files: Makefile
# expect: makefile: der Image-Testlauf traegt einen Prozess-Deckel (--pids-limit)
#
# Entfernt `--pids-limit $(TEST_PIDS_LIMIT)` aus dem docker-run-Aufruf des
# test-go-image-Rezepts (Makefile). Der Prozess-Deckel haengt an keiner Verhaltens-
# Zusage des geprueften Codes: `make test-go-image` selbst liefe ohne ihn unveraendert
# durch, weil kein Test der Go-Stufe an der Flag-Zeile haengt. Die bats-Assertion
# haelt die Flag-Zeile textuell fest und faerbt bei ihrer Abwesenheit rot. Seit
# slice-labor-gates-host-rezepte traegt der Deckel allein den opt-in Image-Weg
# (ADR-0109): die docker-Flags im Container-Kontext, nicht das Rezept am Host —
# der Anker versieht deshalb die IMAGE-Zeile, wie der Wächter (`grep
# test-go-image`, test/dockerfile-teststufe.bats).
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, wie test/mutations/264).
set -euo pipefail
sed -i "/^test-go-image:/,/^\$/ s/ --pids-limit \$(TEST_PIDS_LIMIT)//" Makefile
