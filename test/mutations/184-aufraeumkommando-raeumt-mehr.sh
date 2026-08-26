#!/usr/bin/env bash
# files: internal/emit/templates/enforce/erfassung.mk
# expect: TestErfassungFragment_ZielUndNichtZusage
# verify: test-go
#
# GIBT DEM AUFRAEUM-KOMMANDO EINEN ZWEITEN PFAD: `rm -rf` trifft dann neben dem
# Span-Bestand noch ein Verzeichnis, das dem Adopter gehoert.
#
# Der Plan nennt das als schaerfstes Risiko dieses Slices: "Ein Aufraeum-Kommando loescht
# fremde Daten. Es entfernt den Bestand eines Adopters, und ein Fehler darin ist
# unumkehrbar." Ein zweites Argument ist die billigste Form dieses Fehlers — es faellt
# beim Lesen kaum auf und wirkt sofort.
#
# DIE MUTATION TRIFFT DIE ECHTE REZEPT-ZEILE, keine nachgebaute. Sie traegt das
# Make-Praefix `@`, und ein Waechter, der es nicht wegliest, sieht `@rm` statt `rm` und
# kann nie ansprechen — genau dieser Fall war einmal toter Code in einem gruenen Gate
# (Review-Befund slice-099 F-1).
#
# Der Pfad steht VOR dem Bestand, weil der Anker sonst die Make-Variable enthielte und
# der Shell-Lint sie in einfachen Anfuehrungszeichen als Kommando-Substitution liest.
# Fuer die geprueste Eigenschaft ist die Reihenfolge ohne Bedeutung: es ist ein Argument
# mehr.
set -euo pipefail
sed -i 's%rm -rf %rm -rf /tmp/ai-harness-init-mutation %' internal/emit/templates/enforce/erfassung.mk
