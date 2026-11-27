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
# Mini-Wurzel: k2 driftet von k1).
#
# ERWARTETER ROT-GRUND: genau jener Test. Der Real-Bestand-Test
# `keys: keine Menge deckt die Record- oder Laufzustands-Ablage` faerbt NICHT
# mit — die committeten Record-Dateien tragen .txt und keine Menge der Tafel
# passt auf sie; die Record-Kopplung am Real-Bestand traegt der Test ueber
# `menge`, und sie misst den Ausschluss nur, wo die Menge die Record-Dateien
# treffen WUERDE. Der Rest der Mengen (targeted find) aendert sich nicht und
# faerbt nicht mit.
set -euo pipefail
sed -i '/[[:space:]]'\''\.\/\.harness\/stamp\/\*\*/d' harness/tools/gates-keys.sh
