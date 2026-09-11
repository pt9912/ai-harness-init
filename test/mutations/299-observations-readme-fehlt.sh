#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# planTemplates schreibt den Register-Ort nicht mehr in den Ausgabe-Plan. Der
# emittierte Bestand ist damit unvollstaendig (im realen Emit fehlte
# docs/plan/planning/observations/README.md, obwohl mitemittierte
# Workflow-Commands den Ort bereits als vorhanden referenzieren). Kompiliert
# weiter.
#
# Das Muster ankert auf dem EINTRAG in die Ziel-Map (`out[observationsReadmeTarget]
# = `), nicht auf der vollen Zeile samt rechter Seite -- die Zuweisung darf ihre
# Formulierung aendern (etwa eine Kopie statt einer Aliasierung), ohne dem Zahn
# die Zaehne zu ziehen. Ersetzt wird nur die linke Seite durch eine Leer-Zuweisung
# (`_ = `): die rechte Seite bleibt stehen und ausgewertet, also bleibt jeder von
# ihr benutzte Import in Gebrauch -- der Eintrag in die Map fehlt trotzdem.
set -euo pipefail
sed -i 's/^\tout\[observationsReadmeTarget\] = /\t_ = /' internal/emit/templates.go
