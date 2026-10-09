#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: TestKotlinHexslice_PaketGleichVerzeichnis
#
# Die Domain-Datei des Kotlin-hexSlice-Skeletts deklariert ein Paket, das nicht ihr
# Verzeichnis ist. Der Build bliebe gruen (Kotlin verlangt Paket == Verzeichnis nicht),
# aber a-check loest Importe ueber den Pfad auf — ein Import dieses Pakets traefe die
# Domain-Schicht nicht mehr (ADR-0088 Festlegung 4).
set -euo pipefail
sed -i 's/^package app\.hexagon\.domain\.example$/package app.hexagon.domain/' internal/gen/kotlin.go
