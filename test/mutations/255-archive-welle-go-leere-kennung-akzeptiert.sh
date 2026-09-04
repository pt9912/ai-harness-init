#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleAufrufFehler
# verify: test-go
#
# TAUSCHT DIE PRUEFUNG NACH DER SCHLEIFE GEGEN EINE UEBER DEM ARGUMENT-FELD: statt
# „keine Kennung gewonnen" fragt der Parser danach „gar kein Argument
# uebergeben". Beides sieht nach derselben Frage aus und ist es nicht.
#
# Der Unterschied ist genau der Bedien-Einstieg. Das Rezept von
# `make archive-welle` gibt dem Traeger `"$(WELLE)"` weiter; ohne gesetztes WELLE
# steht dort eine leere Zeichenkette. Das Argument-Feld hat dann die Laenge eins,
# die Schleife laeuft, und die Kennung bleibt leer — der Lauf ginge weiter und
# suchte eine Welle ohne Namen. Das leere Feld daneben (Aufruf ohne jedes
# Argument) bleibt unter dieser Mutation Exit 2 und deckt sie darum nicht auf.
set -euo pipefail
sed -i 's/^\tif welle == "" {$/\tif len(args) == 0 {/' cmd/ai-harness-init/archive_welle.go
