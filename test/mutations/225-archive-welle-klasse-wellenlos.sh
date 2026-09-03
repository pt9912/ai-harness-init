#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: Klasse wellenlos: das Welle-Feld sagt 'ohne Welle'
#
# Laesst die Klasse `wellenlos` auf `fremd` fallen. Die Einsammel-Regel sammelt
# danach nur noch die Mitglieder der Welle ein; die wellenlosen Slices seit der
# letzten Closure bleiben liegen, und die Archivierung waere still
# unvollstaendig — ein Zustand, den kein Gate liest, weil das Zip opak ist.
# Der bats-Fall zur Klasse `wellenlos` faellt dadurch, der zur Klasse `fremd`
# nicht: nur so ist die Mutation von einem Kollaps aller drei Klassen
# unterscheidbar.
set -euo pipefail
sed -i 's/wellenlos\\n/fremd\\n/' harness/tools/archive-welle.sh
