#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramKeepsNavigationOnMultilineCommands
#
# ZEILENGRENZE: `commandProgram` fragt nicht mehr, ob die Kommandozeile ein Zeilenende
# zwischen zwei Woertern traegt. Danach sucht die Navigations-Erkennung das Segment-Ende ueber
# alle Zeilen, und `cd /x` + Zeilenende + `echo hi; SECRETWORD` nennt `SECRETWORD` als
# `program` — ein Wort einer Folgezeile.
#
# DER PFAD IST STILL: kein Abbruch, das Programm wird nur falsch. Rot wird der Waechter, der
# die GESCHRIEBENE Zeile auf das Wort der Folgezeile liest und `cd` erwartet; `# expect:`
# nennt ihn. Die Zeilen der uebrigen Tests tragen kein Zeilenende zwischen Woertern.
set -euo pipefail
sed -i 's@^\tsingleLine := w.singleLine()$@\tsingleLine := true@' internal/span/span.go
