#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: eine LEERE Statusdatei zaehlt NICHT als Ergebnis
#
# Nimmt der Statuszeile ihre Inhalts-Pruefung: danach gilt jede vorhandene Datei als
# Ergebnis, gleich was drinsteht. `>"$f"` legt die Datei an, BEVOR es schreibt — ein
# Worker, der dazwischen stirbt (Signal, volle Platte), hinterlaesst eine LEERE
# Statusdatei, ihr leeres Urteil faellt in den else-Zweig, und der verlorene Fall gilt
# als BESTANDEN. Der Lauf bestaetigt daneben seine Vollstaendigkeit und ueberschreibt
# eine Bilanz mit einem Nenner, den ihre Summe nicht deckt.
# Das ist DoD (1) und DoD (3) aus slice-105 in einem Griff — und das stille Gruen im
# Sensor, der alle anderen belegt.
set -euo pipefail
sed -i 's/^status_line_valid() {/status_line_valid() { return 0;/' harness/tools/mutate.sh
