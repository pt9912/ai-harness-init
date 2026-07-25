#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: isolation_path VERWEIGERT ein Ziel unter dem Repo
#
# Dreht die Ortsregel auf ERFOLG: ein Ziel UNTER dem Repo wird dann nicht mehr
# verweigert. Fachlich ist das die slice-044-Falle — ein ungetracktes Verzeichnis im
# Working Tree verschiebt den MR-003-Stop-Hook-Hash und traegt die Mutationen zurueck in
# genau den Baum, den die lesenden Rollen messen. Die Isolation hiesse dann so und waere
# es nicht.
#
# Der Anker ist die EINGERUECKTE nackte `return 1` im case-Zweig von isolation_path
# (einmalig, geprueft) — NICHT das frueher genutzte dest="..."-Muster: das faerbte nur
# die Nicht-Leer-Assertion rot, nicht die Ortsregel selbst (Review F-5, dieselbe
# Klasse wie bei Fall 73).
set -euo pipefail
sed -i 's/^      return 1$/      return 0/' harness/tools/mutate.sh
