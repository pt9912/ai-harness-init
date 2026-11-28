#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestVorschauNenntUmzugsStubsJeVerweisenderDatei
# verify: test-go
#
# ENTHEMMT DIE FUNDE-ZEILE DER VORSCHAU: UmzugsFunde kehrt immer leer zurueck,
# die Vorschau meldet keine Referenzen aus dem Nachzug-Nicht-Suchraum und sagt
# ausgeschrieben "keine" — im Vorher-Bericht ist damit UNsichtbar, was der
# Nachzug nicht erreicht und der Umzugs-Stub traegt (ADR-0112 Festlegung 3).
#
# Der Fall haelt die Verdrahtung am Bericht (lesende Seite, Festlegung 3), nicht
# den Schreiber der Stubs — den misst 826. Fail-closed bleibt ueber die Zeile
# erhalten: sie stellt die Stub-Menge als Pflicht vor die zwei Commits; ohne
# Stub-Mechanik im Werkzeug bricht der Lauf an ihr.
set -euo pipefail
sed -i 's/^func UmzugsFunde(root string, dateien, verschwindend \[\]string) (\[\]string, error) {$/func UmzugsFunde(root string, dateien, verschwindend []string) ([]string, error) {\n\treturn nil, nil/' \
	internal/archive/vorschau.go
