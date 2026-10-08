#!/usr/bin/env bash
# files: Makefile
# verify: test-bats
# expect: gate-nachweis: an der Kante haengen genau die erwarteten Checks
#
# Nimmt `register-ausgang` aus den Voraussetzungen von `record-gates`. Der Waechter laeuft dann
# nicht mehr in `make gates`, und der Stempel deckt einen Baum, in dem ein Registereintrag ueber
# der 3x-Schwelle ohne Ausgang stehen kann (ADR-0085). Die uebrigen Kanten-Zusagen bleiben gruen;
# rot faerbt allein die Erwartungsliste in test/gate-nachweis-kante.bats.
#
# Das Muster trifft den Namen nur innerhalb der record-gates-Zeile; das Ziel `register-ausgang:`
# selbst bleibt stehen.
set -euo pipefail
sed -i '/^record-gates: /s/ register-ausgang / /' Makefile
