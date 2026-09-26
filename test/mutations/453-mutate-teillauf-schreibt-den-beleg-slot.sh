#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Teillauf schreibt den Beleg-Slot nie
#
# Ruft main() im Teillauf-Zweig zusaetzlich `finalize_belief` auf. Ein gruener Teillauf
# schriebe dann den Beleg-Slot -- die Aussage „der letzte VOLLE Lauf war gruen" wuerde von
# einem Lauf ueber weniger Faellen bestaetigt, und ein spaeterer, unerzwungener Aufruf
# uebersprange den vollen Satz auf Grund eines Teilergebnisses.
#
# Anker: die Zeile `    report_partial ...` (vier Leerzeichen) ist der einzige Aufruf von
# report_partial in main(); die Definition steht ohne Einrueckung.
set -euo pipefail
sed -i "s/^    report_partial .*/&\n    finalize_belief \"\$belief_key\"/" harness/tools/mutate.sh
