#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestFailedAgentCallCapturesNothing
#
# LAESST `cache_read_input_tokens` OHNE WERT WEG: `omitzero` nimmt das Feld aus der
# Zeile, sobald der Zaehler keinen Wert hat. Der Cache-Status ist Pflicht (SPEC-024);
# im fehlgeschlagenen `Agent`-Aufruf traegt er die Kennzeichnung statt zu fehlen
# (SPEC-077). Der Fall bindet die `mustContain`-Zeile dieses Feldes im
# Fehlschlag-Waechter.
set -euo pipefail
sed -i 's@json:"cache_read_input_tokens"@json:"cache_read_input_tokens,omitzero"@' internal/span/response.go
