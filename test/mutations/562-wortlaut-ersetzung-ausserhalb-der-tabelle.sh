#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestWortlautNeutralisierungen_EineTabelle
#
# EINE WORTLAUT-ERSETZUNG AN DER TABELLE VORBEI: neutralisiereJeDatei ersetzt vor dem
# switch einen eigenen Marker (const bodyMarker) per strings.ReplaceAll(body, …), ohne
# Zeile in WortlautNeutralisierungen. Der bats-Fall am vendored Baum saehe diesen Marker
# nie; der go/ast-Test meldet:
#   templates.go:<n>: strings.ReplaceAll in neutralisiereJeDatei bezieht seinen Marker nicht aus WortlautNeutralisierungen
# Der Fall bindet die Aufruf-Pruefung (LH-FA-02).
set -euo pipefail
sed -i '/^func neutralisiereJeDatei/,/^\tswitch rel {$/s/^\tswitch rel {$/\tbody = strings.ReplaceAll(body, bodyMarker, "")\n\tswitch rel {/' internal/emit/templates.go
printf 'const bodyMarker = "xyz"\n' >> internal/emit/templates.go
