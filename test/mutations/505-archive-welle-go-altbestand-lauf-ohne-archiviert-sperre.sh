#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestArchiveWelleAltbestandZweiterLaufSperrtAnArchiviert
# verify: test-go
#
# ADR-0041 Festlegung 2: der Schluessel `altbestand` traegt genau einen Lauf; ein
# zweiter bricht an `archiviert` ab. Die Mutation schaltet die Sperre fuer den
# Schluessel ab. Der Fall deckt den STILLEN Pfad: vor dem zweiten Lauf liegt ein
# wellenloser Slice flach, kein anderer Ausgang beendet ihn, und er schriebe ein
# zweites Archiv ueber das erste.
set -euo pipefail
sed -i 's/^\tif b\.Archiviert {$/\tif b.Archiviert \&\& b.Welle != AltbestandSchluessel {/' internal/archive/vorschau.go
