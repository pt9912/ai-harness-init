#!/usr/bin/env bash
# files: harness/tools/gates-keys.sh
# expect: keys: der Walk liegt ganz in der Tafel-Vereinigung oder einer deklarierten Rest-Klasse; ein undeklarierter Neuzugang faellt auf
# verify: test-bats
#
# NIMMT DER MENGE_REST DIE ALTBESTAND-ABGABE: das Sammel-Archiv
# done/altbestand/archive.zip (die Ablage des Altbestand-Laufs, ADR-0041) liegt
# dann im Bauch-Walk ausserhalb jeder Tafel-Menge und jeder deklarierten
# Rest-Klasse — der undeklarierte Neuzugang faellt als List-Zeile auf, und der
# rest-leer-Fall am realen Baum (Zusage rest-Zeilen: 0) faellt am echten
# Archiv-Eintrag wie am Fixture-Zug der tests.
#
# GRENZE: der Fall enthemmt die Deklaration, nicht die Walk-Semantik — das Archiv
# ist das Lauf-Urteil des archivierenden Vorgangs und bleibt ohne Check der
# Kante, je deklarierter Rest-Klasse (siehe Kopf des Satzerzeugers).
set -euo pipefail
sed -i '/altbestand/d' harness/tools/gates-keys.sh
