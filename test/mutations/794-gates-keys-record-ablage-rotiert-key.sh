#!/usr/bin/env bash
# files: harness/tools/gates-keys.sh
# expect: keys: ein Record-Zug unter .harness/stamp bewegt keinen je-Check-Key
# verify: test-bats
#
# ENTLEERT DEN Record-Ablage-AUSSCHLUSS DES BAUCH-WALKS (MENGE_AUSSCHLUESS): die
# Record-Dateien unter .harness/stamp/mutate/ (ADR-0103) landen in der Bauch-Menge
# des Satzerzeugers, und der Record-only-Zug rotiert den je-Check-Key — genau was
# ADR-0108 Festlegung 2 verweigert. Färbt den Fixture-Test `keys: ein Record-Zug
# unter .harness/stamp bewegt keinen je-Check-Key` rot (Record-Zug in der
# Mini-Wurzel) und den Real-Bestand-Test `keys: keine Menge deckt die Record- oder
# Laufzustands-Ablage` (die committeten Record-Dateien im Bauch von comment-claims).
#
# ERWARTETER ROT-GRUND: die zwei oben genannten Tests; die übrigen Mengen (targeted
# find) ändern sich nicht und faerben nicht mit.
set -euo pipefail
sed -i '/[[:space:]]\..\/\.harness\/stamp.*/d' harness/tools/gates-keys.sh
