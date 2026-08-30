#!/usr/bin/env bash
# files: harness/conventions.md
# expect: d-check.yml: jede Top-Level-ignore-refs-Ausnahme deckt hoechstens einen Markdown-Link ihrer Quelldatei
#
# Haengt einen ZWEITEN Markdown-Link auf das ausgenommene Ziel an. Der Top-Level-
# `ignore-refs`-Eintrag in .d-check.yml matcht auf dem aufgeloesten Pfad, nicht auf der
# Zeile: der zweite Link faellt damit mit aus der Pruefung, und `make docs-check` bleibt
# gruen. Genau diese Restbreite ist der Grund, aus dem der Waechter existiert — ohne ihn
# ist die Zusage "die Ausnahme deckt genau eine Referenz" unbelegt (ADR-0026).
#
# Der Pfad ist anders geschrieben als der echte Verweis (`../harness/..` statt `../`),
# damit die Mutation die AUFLOESUNG trifft und nicht den Substring: ein Waechter, der
# den Link-Text vergleicht statt ihn aufzuloesen, kaeme hier durch.
set -euo pipefail
printf '%s\n' '' '[zweiter Verweis](../harness/../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#irgendwo)' >> harness/conventions.md
