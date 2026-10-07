#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestCacheStatusIsMarkedNotKnown
#
# LAESST `cache_read_input_tokens` OHNE WERT WEG: `omitzero` nimmt das Feld aus der
# Zeile, sobald der Zaehler keinen Wert hat. Der Cache-Status ist Pflicht (SPEC-024)
# und ohne Wert nie abwesend (SPEC-087). Jeder Span ohne Zaehler laeuft durch dieselbe
# Marshal-Stelle; der Fall bindet die `mustContain`-Zeile dieses Feldes im
# Kennzeichnungs-Waechter.
set -euo pipefail
sed -i 's@json:"cache_read_input_tokens"@json:"cache_read_input_tokens,omitzero"@' internal/span/response.go
