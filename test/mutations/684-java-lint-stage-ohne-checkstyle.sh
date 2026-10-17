#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: full-smoke: FEHLER — make gates nach add-lang java ohne Beleg fuer
# verify: full-smoke
#
# Die lint-Stage des Java-Dockerfiles fuehrt keinen Checkstyle-Schritt mehr (`RUN true`):
# make gates bleibt gruen, das Gate lief aber nicht. Die Go-Tests koppeln nur Stage-NAMEN an
# das Fragment; der Beleg-Marker der Stufe "add-lang java apps/java" in
# harness/tools/full-smoke.sh liest den checkstyle-Schritt im BuildKit-Protokoll (LH-QA-01).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^RUN gradle --no-daemon checkstyleMain checkstyleTest$/RUN true/' internal/gen/java.go
