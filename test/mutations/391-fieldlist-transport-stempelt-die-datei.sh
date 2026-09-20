#!/usr/bin/env bash
# files: internal/emit/fieldlist.go
# expect: TestFeldliste_LiegtVerbatimImZiel
#
# HAENGT DEM TRANSPORT EINEN STEMPEL VOR: emit.FieldList() schreibt dann nicht mehr
# BYTE-GLEICH, was span.FieldList() ausdrueckt (ADR-0022 Festlegung 7, Muster MR-010).
# Die zwei Seiten des Vergleichs sind unterschiedliche Funktionen — der Transport
# (emit.FieldList) gegen den Ausdruck (span.FieldList) —, die Pruefung misst darum nicht
# Selbstkonsistenz, sondern die Verbatim-Zusage selbst.
set -euo pipefail
sed -i 's@return writeFileMode(targetDir, FieldListPath, \[\]byte(doc), 0o644)@doc = "<!-- generiert -->\\n" + doc; return writeFileMode(targetDir, FieldListPath, []byte(doc), 0o644)@' internal/emit/fieldlist.go
