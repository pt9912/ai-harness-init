#!/usr/bin/env bash
# files: harness/tools/full-smoke.sh
# expect: schreiber-form: der Treiber liest den Satzerzeuger
# verify: test-bats
#
# DER SCHREIBER STAPELT DEN BAUM-HASH STATT DER MENGEN-RECHNUNG (ADR-0113
# Festlegung 4/6, b-1): der Stempel-Zug am gruenden Ende liest working-tree-hash.sh
# statt dem Satzerzeuger `alle` — die Werte behaupten dann die Vorlagen-Mengen,
# ueber die keine Rechnung fuhr (LH-QA-01), und der Konsum wuerde sie je gegen
# eine fremde Frisch-Rechnung lesen.
#
# Waechter ist der Form-Fall in test/full-smoke-varianten-keys.bats
# ("schreiber-form: der Treiber liest den Satzerzeuger `alle` und schreibt je
# Variante die Zwei-Zeilen-Form, ohne Baum-Hash (ADR-0113 Festlegung 4)"): er
# haelt die Schreiber-Form am realen Treiber-Skript und faellt, sobald die Ernte
# nicht mehr vom Satzerzeuger kommt. Eine Menge-Gleichheit misst er nicht — die
# behauptete Wirkungsgrenze steht am Fall; der reale Lauf am gebootstrappten
# Bestand bleibt die Grenze der hermetischen Form.
set -euo pipefail
sed -i 's@HIER/full-smoke-varianten.sh" alle@HIER/working-tree-hash.sh@' harness/tools/full-smoke.sh
