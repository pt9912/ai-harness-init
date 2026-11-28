#!/usr/bin/env bash
# files: .github/workflows/ci.yml
# expect: ci-verdrahtung: der push-main-Gates-Job konsultiert die transportierten Keys unforced
# verify: test-bats
#
# DER TRANSPORT-KEY WIRD STILL NICHT MEHR KONSULTIERT (ADR-0111 Festlegung 2):
# der push-main-Zweig des Gates-Jobs faehrt ueber GATES_FORCE=1 — die
# Skip-Konsultation der committeten Keys ist still aus der Verdrahtung gefallen,
# jeder Push zahlt wieder den vollen Lauf, und die SKIP-Form behauptet nichts
# mehr, was die Datei nicht traegt.
#
# Waechter ist der Verdrahtungs-Fall in test/ci-stempel-committed.bats
# ("ci-verdrahtung: der push-main-Gates-Job konsultiert die transportierten
# Keys unforced"): er zählt den unforced `make gates`-Aufruf im push-main-Zweig
# und faellt, sobald derselbe Zweig erzwungen voll faehrt.
set -euo pipefail
sed -i 's/^            make gates$/            GATES_FORCE=1 make gates/' .github/workflows/ci.yml
