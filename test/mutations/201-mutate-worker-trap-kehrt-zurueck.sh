#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Worker unter TERM meldet KEIN Fall-Urteil
#
# Legt den Signal-Zweig des WORKERS wieder auf seinen EXIT-Zweig — der Zustand vor der
# Fix-Runde zu slice-117. worker_cleanup kehrt zurueck, bash nimmt den Lauf an der
# unterbrochenen Stelle wieder auf, und das trifft mitten in run_case: das Fall-Backup ist
# weggeraeumt, verify.log liegt darin, und der Fall meldet danach
# `rot, aber '<expect>' faellt nicht — falscher Grund`.
# Ein FALSCHES Fall-Urteil OHNE Signal von aussen — das TERM schickt stop_workers selbst,
# sobald die Zeitschranke greift. Derselbe Defekt, den der Slice im Elternprozess behebt.
set -euo pipefail
sed -i "s/^  trap 'worker_on_signal INT' INT\$/  trap 'worker_cleanup' INT/" harness/tools/mutate.sh
sed -i "s/^  trap 'worker_on_signal TERM' TERM\$/  trap 'worker_cleanup' TERM/" harness/tools/mutate.sh
