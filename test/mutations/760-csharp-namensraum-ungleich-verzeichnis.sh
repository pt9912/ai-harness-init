#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestCsharpHexslice_NamensraumGleichVerzeichnis
#
# Die Domain-Datei deklariert einen Namensraum, der ihrem Verzeichnis nicht folgt: a-check bildet
# den Namensraum eines using auf einen Pfad ab, ein solches using loest nicht auf und faerbt nichts
# (ADR-0096 Festlegung 5, Skelett-Pflicht (a)).
set -euo pipefail
sed -i 's/namespace App\.Hexagon\.Domain\.Example;/namespace App.Domain.Example;/' internal/gen/csharp_hexslice.go
