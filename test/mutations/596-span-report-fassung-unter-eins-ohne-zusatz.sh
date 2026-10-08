#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_FassungUnterEinsIstDemLeserUnbekannt
#
# KENNZEICHNET NUR FASSUNGEN UEBER DER DES LESERS. Eine Fassung unter 1, die die Tabelle in
# SPEC-089 nicht fuehrt, stuende dann ohne den Zusatz `dem Leser unbekannt` wie eine
# beschriebene Fassung im Bericht.
set -euo pipefail
sed -i 's/^\t\tif n < 1 || n > span.CurrentRuleVersion {$/\t\tif n > span.CurrentRuleVersion {/' internal/report/report.go
