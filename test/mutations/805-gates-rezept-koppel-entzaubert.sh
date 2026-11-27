#!/usr/bin/env bash
# files: Makefile harness/tools/gates-keys.sh
# expect: keys: die Rezeptzeilen der Kante liegen in den Mengen (Makefile je Check)
# verify: test-bats
#
# FAEHRT DIE Rezept-Kopplung DES Satzerzeugers zurück (Review F-1 des Slice
# slice-gates-pruefgegenstand-stempel-v1): die Deletion der './Makefile'-Zeilen
# aus ALLEN Tafel-Mengen entzieht je Check der Kante seine Rezeptzeile — der
# Rezept-Edit (`golangci-lint run ./...`, zweite sed, Anker am realen Rezept
# nach MR-071) würde danach keinen je-Check-Key mehr drehen, und der Fast-Pfad
# SKIPpt über alter Urteils-Basis. Die Deletion ist die ROT-Form und faerbt den
# Wächter `keys: die Rezeptzeilen der Kante liegen in den Mengen` an JEDEM Check
# der Kante rot; der Rezept-Anker am Makefile greift allein (er ist der Beleg
# der Fehlfunktions-Lage, nicht ein faerbender Zahn — der faerbende Zahn ist
# der Wächter über der Tafel). GRUEN bleiben der uebrige Wächter-Satz: die
# behavioralen Formen (Skript-Zeile, Baubasis) hängen an anderen Eintraegen,
# und der Rezept-Edit am Makefile bewegt keinen Key mehr NICHT, weil die
# Kante `record-gates:` unverändert bleibt — der Kanten-Wächter liest sie.
set -euo pipefail
sed -i 's/^\t\(golangci-lint run \)\.\/\.\.\./\t\1.\/... -einstellung/' Makefile
sed -i "/'\.\/Makefile'/d" harness/tools/gates-keys.sh
