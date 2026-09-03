#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: Arbeitsbaum: UNTRACKTE Dateien allein sind schon ein Grund
#
# Laesst die Vorbedingung "sauberer Arbeitsbaum" wieder nur getrackte Dateien
# sehen. Der Aufruf liefe dann ueber einem Baum mit untracktem Fremdbestand
# durch — und der Wave-Self-Close-Commit, der eine Punkt, an dem ein Audit die
# Welle schliessen sieht, truege Inhalt, den dort niemand sucht.
set -euo pipefail
sed -i "s/untrackt=\$((untrackt + 1))/continue/" harness/tools/archive-welle.sh
