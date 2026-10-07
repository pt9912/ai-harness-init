#!/usr/bin/env bash
# files: internal/emit/selbstpruefung.go
# expect: TestSelbstpruefung_DerGenannteVorgabeOrtWirdNieUeberschrieben
# verify: test-go
#
# SETZT DEN VORGABE-ORT DER SELBSTPRUEFUNG AUF EINEN PFAD UNTER harness/mk/ ZURUECK.
#
# Danach nennt die Konstante einen Ort, den die Koepfe der Vorlagen nicht mehr nennen
# (sie zeigen auf repo.mk, ADR-0080 Festlegung 4). Der Test haelt Konstante und Koepfe
# zusammen.
set -euo pipefail
sed -i 's|SelbstpruefungVorgabeOrt = RepoMkPath|SelbstpruefungVorgabeOrt = "harness/mk/vorgaben.mk"|' internal/emit/selbstpruefung.go
