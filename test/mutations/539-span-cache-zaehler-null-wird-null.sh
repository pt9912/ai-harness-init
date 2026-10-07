#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestCacheStatusIsMarkedNotKnown
#
# LIEST `null` ALS ZAHL 0: ohne die null-Pruefung in count laesst json.Unmarshal den
# int64 bei `null` fehlerfrei auf 0. Ein `usage`-Objekt mit
# `"cache_read_input_tokens":null` steht dann als `"cache_read_input_tokens":0` in der
# Zeile, und ein Leser bekommt `null` als Wert 0 — beides eine Messung, die nie
# stattfand (SPEC-087). Die Stelle ist die eine, durch die Erfassung und Lesen eines
# Zaehlers laufen (count).
set -euo pipefail
sed -i 's@^\tif isNull(v) {$@\tif false \&\& isNull(v) {@' internal/span/response.go
