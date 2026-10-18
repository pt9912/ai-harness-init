#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: TestJavaHexslice_PaketGleichVerzeichnis
#
# Die Domain-Datei des Java-hexSlice-Skeletts deklariert ein Paket, das nicht ihr
# Verzeichnis ist. Der Build bliebe gruen (javac verlangt Paket == Verzeichnis fuer die
# Quelldatei nicht), aber a-check loest Importe ueber den Pfad auf — ein Import dieses
# Pakets traefe die Domain-Schicht nicht mehr (ADR-0094 Festlegung 4).
set -euo pipefail
sed -i 's/^package app\.hexagon\.domain\.example;$/package app.hexagon.domain;/' internal/gen/java_hexslice.go
