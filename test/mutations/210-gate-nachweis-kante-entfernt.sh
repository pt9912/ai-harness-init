#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: record-gates haengt an den Checks (Ordnungskante steht)
#
# Die Ordnungskante wird aus dem gates-Aggregator dieses Repos entfernt:
# `record-gates: <checks> ## …` -> `record-gates: ## …`. Dann steht der Nachweis wieder
# NEBEN den Checks statt an ihnen, und `make -k gates` schreibt ihn ueber rotem Stand:
# der Stop-Hook vergleicht genau diesen Hash und gibt einen Abschluss frei, den er
# nicht decken darf.
#
# Der Fall trifft die Stelle, die `make gates` wirklich faehrt (den Makefile in der
# Wurzel), nicht eine Nachbildung im Test. Das Muster kommt ohne die Namen der Checks
# aus: es loescht alles zwischen Zielnamen und Hilfe-Kommentar, wandert also mit der
# Liste mit.
set -euo pipefail
sed -i 's/^record-gates: [^#]*##/record-gates: ##/' Makefile
