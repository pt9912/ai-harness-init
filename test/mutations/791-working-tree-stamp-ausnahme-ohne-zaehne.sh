#!/usr/bin/env bash
# files: harness/tools/working-tree-hash.sh
# expect: stamp-ausnahme: ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht
#
# ENTLEERT die Deklaration der Hash-Ausnahme (ADR-0103 Festlegung 2): die Liste
# traegt keinen Baum mehr, der die Records deckt — jede Stamp-Datei landet wieder
# in der Hashmenge, ein Record-Ablagezug bewegt den Nachweis-Hash wie ein
# ungedecktes Artefakt. Färbt die Stamp-Form-Fälle von
# test/working-tree-hash-abnahme.bats rot — den Fall
# `stamp-ausnahme: ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht`,
# und Fall 4 trägt denselben Bruch-Fall in der Determinismus-Fassung (sein
# Setup enthält Stamp-Inhalt, der unter der entleerten Liste über den
# fail-closed-Zweig bricht); der fail-closed-Zweig bleibt als Code unberührt
# (Fall 2 bleibt grün, der Fehler trifft seine Fehlerstelle nicht).
set -euo pipefail
# Die Deklaration ist eine mehrzeilige Form (die zwei committeten state-Klassen
# je ADR-0111 Festlegung 1/4 liegen auf eigenen Zeilen); `sed -z` liest die Datei
# als einen Record und ersetzt den ganzen Block.
sed -zE 's@HASH_AUSNAHMEN=\([^\)]*\)@HASH_AUSNAHMEN=(.nicht-gedeckt-vorhanden)@' harness/tools/working-tree-hash.sh
