#!/usr/bin/env bash
# files: internal/emit/werkzeugindex.go
# expect: TestWerkzeugIndex_GrenzeNenntDisjunktheitsBedingung
# verify: test-go
#
# SETZT IN DER GRENZ-ZEILE DES WERKZEUG-TEILS DIE PIN-AUSSAGE STATT DES BEDINGUNGSSATZES EIN.
#
# Danach sagt harness/mk/ai-harness-init.md, der gepinnte d-check pruefe die Disjunktheit nicht,
# und nennt die drei Bedingungen, die sonst-Haelfte und die Grenze des Sensors nicht mehr
# (ADR-0082 Festlegung 2). Der Test liest den geschriebenen Werkzeug-Teil, nicht die Konstante.
set -euo pipefail
sed -i 's/ . + DisjunktheitsBedingung + .$/ Der gepinnte d-check prüft die Disjunktheit nicht./' internal/emit/werkzeugindex.go
