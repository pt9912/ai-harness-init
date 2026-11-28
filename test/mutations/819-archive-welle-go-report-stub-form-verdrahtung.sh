#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenBrichtBeiVerletzterReportStubFormAb
# verify: test-go
#
# ENTHEMMT DIE FORM-VERDRAHTUNG DES REPORT-ZWEIGS: reportForm kehrt immer nil
# zurueck, der Lauf schreibt den form-widrigen Report-Stub und committet ihn.
#
# Der Fall ist NICHT 243: die enthemmt die FormOK-Verdrahtung der
# Umzug-Stubs an der SLICE-Vorlage — die bricht im Form-widrig-Baum vorher, noch
# ehe der Report-Zweig laufe. Hier ist die Slice-Vorlage unveraendert, ihre
# Stubs bestehen, und der Report-Zweig bricht an der verletzten REPORT-Vorlage.
set -euo pipefail
sed -i 's/func reportForm(inhalt string) error { return FormOK(inhalt) }/func reportForm(inhalt string) error { return nil }/' \
	internal/archive/anwenden.go
