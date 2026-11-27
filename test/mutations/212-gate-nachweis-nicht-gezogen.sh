#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: verdrahtung: der Wrapper faehrt den vollen Lauf oder genau den Teildrift-Lauf
#
# SEIT ADR-0099 an die Wrapper-Form gezogen — der Anker misst gegen den Quell-Bestand
# (MR-071): der vormals gemutate Text `gates: record-gates` existiert nicht mehr, und
# `gates` zieht den Nachweis seitdem ueber den Wrapper. Die Weiterleitung wird entfernt:
# alle `exec make record-gates`-Zeilen — die zwei eingerueckten Fail-Pfade wie die
# Endzeile — werden zu `exit 0`; bei Nicht-Deckung fährt
# gates dann keinen vollen Lauf, und der Stempel entstuende nie. Die Kante bliebe
# stehen, und „kein Stempel ueber rotem Lauf" waere erfuehrt — dadurch, dass gar kein
# Stempel mehr entsteht. Ohne diesen Fall waere die Erfuellung-durch-Wegfall unbewacht.
# SEIT ADR-0108 (Tier 2): der vollen-Lauf-Zahn bleibt; der Teildrift-Lauf
# (`make "${drifted[@]}"`) bleibt unberuehrt, dessen Zuege haengen an den
# Klassifikations-Faelligen von test/mutations/784 und 793.
set -euo pipefail
sed -i "s@^[[:space:]]*exec make record-gates\$@exit 0@" harness/tools/gates-fast.sh
