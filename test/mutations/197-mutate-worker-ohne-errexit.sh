#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Worker BRICHT AB, wenn er seinen Zug nicht protokollieren kann
#
# Setzt errexit im Worker-Rumpf aus — derselbe Zustand, den die fruehere Aufrufform
# `worker_main … || rc=$?` herstellte: bash setzt errexit in jedem Kommando eines
# `||`-Kontextes aus, und zwar bis in die gerufenen Funktionen hinein, also auch in
# run_case. Ein gescheitertes Schreiben bricht den Worker danach nicht mehr ab; er laeuft
# weiter und hinterlaesst die leere Statusdatei, die Fall 196 bewacht. Zwei Abwehrlinien
# gegen dasselbe stille Gruen, jede fuer sich gemessen.
set -euo pipefail
sed -i 's/^worker_main() {/worker_main() {\n  set +e/' harness/tools/mutate.sh
