#!/usr/bin/env bash
# files: internal/emit/templates/enforce/hooks-install.mk
# expect: TestHooksInstallFragment_TraegtDieReichweite
# verify: test-go
#
# NIMMT DEM AKTIVIERUNGS-FRAGMENT DIE REICHWEITEN-ZEILE: der Traeger wird danach
# weiter genannt und aktiviert, aber kein Wort sagt mehr, dass die zweite Haelfte der
# Traceability-Zusage von einem Commit-Waechter nicht pruefbar ist.
#
# Das ist die Zusage ohne ihre Grenze: ein Traeger, der ueber seinem Pruefbereich als
# Zaun gelesen wird, behauptet mehr, als er misst (LH-QA-01). Die Grenze ist keine
# Nebenbemerkung — sie ist der Grund, warum der Satz daneben stehen muss.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Text des
# Fragments, nicht seine Wirkung. Ein `make full-smoke` liest dieselbe Zeile im
# gebootstrappten Ziel, kostet aber den vollen E2E-Lauf ueber drei Varianten.
set -euo pipefail
sed -i '/nicht mechanisch pruefbar/d' internal/emit/templates/enforce/hooks-install.mk
