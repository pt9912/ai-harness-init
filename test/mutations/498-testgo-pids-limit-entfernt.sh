#!/usr/bin/env bash
# files: Makefile
# expect: makefile: der Go-Testlauf traegt einen Prozess-Deckel (--pids-limit)
#
# Entfernt `--pids-limit $(TEST_PIDS_LIMIT)` aus dem docker-run-Aufruf des
# test-go-Rezepts (Makefile). Der Prozess-Deckel haengt an keiner Verhaltens-
# Zusage des geprueften Codes: `make test-go` selbst liefe ohne ihn unveraendert
# durch, weil kein Test der Go-Stufe an der Flag-Zeile haengt. Die bats-Assertion
# haelt die Flag-Zeile textuell fest und faerbt bei ihrer Abwesenheit rot.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, wie test/mutations/264).
set -euo pipefail
sed -i "/^test-go:/,/^\$/ s/ --pids-limit \$(TEST_PIDS_LIMIT)//" Makefile
