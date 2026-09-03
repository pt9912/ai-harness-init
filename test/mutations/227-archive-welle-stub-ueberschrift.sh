#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: Stub-Form: stehengebliebene Abschnittsueberschrift faerbt rot — die tragende Haelfte
#
# Nimmt der Stub-Form-Pruefung ihre tragende Haelfte: den Blick auf
# stehengebliebene Abschnittsueberschriften. Der Archiv-Zeiger allein bleibt
# geprueft — und genau das ist der Zustand, den die Regel benennt: ein Stub mit
# Zeiger und vollem Text waere die Archivierung, die es nicht gab.
set -euo pipefail
sed -i 's|^.*grep -q .\^##.*|  if false; then|' harness/tools/archive-welle.sh
