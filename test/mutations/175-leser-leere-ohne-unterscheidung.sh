#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_LeererBestandNenntSeineLeere
# verify: test-go
#
# MACHT AUS ZWEI LEEREN EINE: der Zweig fuer den Bestand ohne jede Zeile wird nie
# genommen, und ein leerer Bestand bekommt die Meldung des zaehlerlosen.
#
# Beide sehen beim Leser gleich aus, und das ist die Falle. Ohne Zeile gibt es nichts,
# was Zaehler tragen koennte: die Leere kommt dann von einem Traeger, der nicht liegt —
# ein frischer Klon hat ihn nicht. Die Meldung "die Zaehler kommen aus der Mechanik
# nicht" waere in genau diesem Fall eine falsche Begruendung, und ein Adopter suchte den
# Fehler bei seinem Agenten-Werkzeug statt bei der fehlenden Erfassung.
set -euo pipefail
sed -i 's@^	case b.Zeilen == 0:$@	case b.Zeilen < 0:@' internal/report/report.go
