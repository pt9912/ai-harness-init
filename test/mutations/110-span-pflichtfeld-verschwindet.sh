#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestMandatoryFieldsAlwaysPresent
#
# Haengt `omitempty` an ein PFLICHT-Feld (`tool_use_id`). Der Span bleibt
# wohlgeformtes JSON — und genau das ist die Gefahr: bei leerem Wert verschwindet das
# Feld, und der Leser sieht nicht das Fehlen, sondern gar nichts.
#
# Die Pflicht-Spalte in spec/spezifikation.md §5 ist eine Zusage an den AUSWERTER: er darf sich darauf
# verlassen, dass die Achse da ist, um zu erkennen, dass ihr Wert fehlt. Ein
# stillschweigend weggelassenes Feld ist der Unterschied zwischen "unbekannt" und
# "nicht vorhanden" — Modul 15 nennt genau ihn als das, was ein Audit-Schema tragen
# muss. Dies ist der erste der zwei Zaehne aus slice-059 DoD (3): ein Span ohne
# Pflicht-Feld.
set -euo pipefail
sed -i 's@json:"tool_use_id"@json:"tool_use_id,omitempty"@' internal/span/emit.go
