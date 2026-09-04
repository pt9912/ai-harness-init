#!/usr/bin/env bash
# files: harness/conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md
# expect: d-check.yml: jede Top-Level-ignore-refs-Ausnahme deckt hoechstens einen Markdown-Link ihrer Quelldatei
#
# Haengt einen ZWEITEN Markdown-Link auf das ausgenommene Ziel an. Der Top-Level-
# `ignore-refs`-Eintrag in .d-check.yml matcht auf dem aufgeloesten Pfad, nicht auf der
# Zeile: der zweite Link faellt damit mit aus der Pruefung, und `make docs-check` bleibt
# gruen. Genau diese Restbreite ist der Grund, aus dem der Waechter existiert — ohne ihn
# ist die Zusage "die Ausnahme deckt genau eine Referenz" unbelegt (ADR-0026).
#
# DIE DATEI IST DIE, DIE `- in:` NENNT, und keine andere: der Waechter zaehlt Links je
# PAAR aus der Config. Ein Anhang an eine Datei, die kein Paar nennt, aendert die Zahl
# des Paares nicht — die Mutation griffe (die Datei ist veraendert) und der Waechter
# bliebe trotzdem gruen. Der Eintrag zeigt seit ADR-0032 auf den ausgelagerten
# MR-021-Rumpf; die Ausnahme selbst ist dieselbe geblieben.
#
# Der Pfad ist anders geschrieben als der echte Verweis (`../../harness/..` statt
# `../../`), damit die Mutation die AUFLOESUNG trifft und nicht den Substring: ein
# Waechter, der den Link-Text vergleicht statt ihn aufzuloesen, kaeme hier durch. Die
# zwei Aufstiege am Anfang sind die Tiefe der Quelldatei — sie liegt im
# Eintrags-Verzeichnis unter harness/, nicht flach daneben.
set -euo pipefail
printf '%s\n' '' '[zweiter Verweis](../../harness/../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#irgendwo)' \
  >> harness/conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md
