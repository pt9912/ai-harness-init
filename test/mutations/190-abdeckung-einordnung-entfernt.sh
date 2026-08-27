#!/usr/bin/env bash
# files: harness/tools/full-smoke.sh
# expect: jede make-Stufe mit eigenem Exit-Code traegt eine Einordnung
# verify: test-bats
#
# NIMMT EINEM ABSCHNITT SEINE EINORDNUNG: die Stufe, die im emittierten --lang-go-Ziel
# make gates faehrt, meldet ihren Fehlschlag danach wieder ohne Ausgang.
#
# WAS DAS MISST, UND WAS 187 BIS 189 NICHT MESSEN: jene halten den Einordner und den
# einen verdrahteten Punkt, den Fall 189 durchlaeuft. Die ABDECKUNGS-ZUSAGE — dass jeder
# Abschnitt, der ein Bild anfordern kann, seinen Ausgang nennt — haengt an keinem von
# ihnen. Ohne diesen Fall laesst sich jeder der uebrigen Verdrahtungspunkte entfernen,
# ohne dass ein Gate rot wird; die Zusage waere dann Text ohne Sensor (AGENTS.md 3.6).
#
# DIE ZWEITE DRIFT-RICHTUNG — eine NEU eingefuegte Stufe ohne Einordnung — faerbt
# denselben bats-Fall rot, weil er die Abschnitte aus dem Sensor-Text aufzaehlt statt
# aus einer gepflegten Liste. Sie braucht deshalb keinen zweiten Mutations-Fall; ein
# Fall, der Text einfuegt, mutierte die Form der Einfuegung mit und nicht die Zusage.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen wird der TEXT von
# harness/tools/full-smoke.sh. Ein voller full-smoke-Lauf bewiese hier nichts — ein
# gruener Lauf ruft die Einordnung nie, und ein roter trifft genau einen Abschnitt.
set -euo pipefail
sed -i '/^\teinordnen "make -j gates im Ziel (--lang go)"/d' harness/tools/full-smoke.sh
