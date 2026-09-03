#!/usr/bin/env bash
# files: internal/archive/collect.go
# expect: TestKlasseVonWellenlosOhneWelle
# verify: test-go
#
# Nimmt der Einsammel-Regel ihre zweite Klasse: ein wellenloser Slice gilt danach
# als fremd. Das ist die stillste der drei Mutationen — die Welle behielte ihre
# Mitglieder, und nur die wellenlose Arbeit seit der letzten Closure bliebe
# ungezaehlt flach liegen. Genau daran haengt auch der Untergrenzen-Waechter: ohne
# die Klasse hat er nichts mehr zu bewachen.
set -euo pipefail
sed -i 's/^\t\treturn Wellenlos$/\t\treturn Fremd/' internal/archive/collect.go
