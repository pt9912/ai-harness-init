#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: die isolierte Kopie liegt AUSSERHALB des Repos
#
# Legt den Kopie-PFAD ins Repo (statt unter die uebergebene Wurzel). Die Ortsregel
# verweigert das zwar — genau darum faellt der Waechter, der prueft, dass eine gueltige
# Wurzel eine Kopie AUSSERHALB liefert.
#
# Dieser Fall ergaenzt Fall 72, er ersetzt ihn nicht: 72 dreht die VERWEIGERUNG auf
# Erfolg, 75 verlegt den PFAD. Als 72 re-verankert wurde, blieb 75 zunaechst weg — und
# damit war der Waechter unbewacht (Review-Runde 2, F-2: „entfernte Mutation = entfernte
# Deckung", die slice-034-Lehre, beim Reparieren eines anderen Befundes reproduziert).
set -euo pipefail
sed -i "s|dest=\"\$1/repo\"|dest=\"\$REPO/.mutate-iso\"|" harness/tools/mutate.sh
