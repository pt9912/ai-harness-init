#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: full-smoke: FEHLER — das Java-Lint bleibt bei einem unbenutzten Import gruen
# verify: full-smoke
#
# UnusedImports verschwindet aus der Checkstyle-Config des Skeletts. Die Go-Tests fassen die
# Config als Text; erst der reale Checkstyle-Lauf der lint-Stage im gebootstrappten Ziel
# zeigt, dass ein unbenutzter Import das Lint nicht mehr faerbt — die Stufe "add-lang java
# apps/java" in harness/tools/full-smoke.sh nimmt ihn real auf (LH-QA-01, ADR-0094 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/<module name="UnusedImports"\/>/d' internal/gen/java.go
