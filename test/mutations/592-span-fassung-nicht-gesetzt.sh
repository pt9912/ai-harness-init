#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestSpanCarriesCurrentRuleVersion
#
# BUILD SETZT DIE FASSUNG NICHT. Das Pflichtfeld `rule_version` steht dann als `0` in
# jeder Zeile — anwesend, aber mit dem Wert, den jeder Leser als *Fassung nicht bekannt*
# liest (SPEC-088). TestMandatoryFieldsAlwaysPresent bleibt dabei gruen, weil er nur die
# Anwesenheit misst; der Wert ist die Zusage dieses Falls.
set -euo pipefail
sed -i '/^\t\tRuleVersion:    CurrentRuleVersion,$/d' internal/span/emit.go
