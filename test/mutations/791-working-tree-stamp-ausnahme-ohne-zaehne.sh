#!/usr/bin/env bash
# files: harness/tools/working-tree-hash.sh
# expect: stamp-ausnahme: ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht
#
# ENTLEERT die Deklaration der Hash-Ausnahme (ADR-0103 Festlegung 2): die Liste
# traegt keinen Baum mehr, der die Records deckt — jede Stamp-Datei landet wieder
# in der Hashmenge, ein Record-Ablagezug bewegt den Nachweis-Hash wie ein
# ungedecktes Artefakt. Faerbt genau den Fall
# `stamp-ausnahme: ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht` in
# test/working-tree-hash-abnahme.bats rot; der fail-closed-Zweig bleibt davon
# unberuehrt (Fall 2 bleibt gruen, der Fehler trifft die Fehlerstelle nicht).
set -euo pipefail
sed -i 's@^HASH_AUSNAHMEN=(\.harness/stamp/mutate)$@HASH_AUSNAHMEN=(.nicht-gedeckt-vorhanden)@' harness/tools/working-tree-hash.sh
