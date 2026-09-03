#!/usr/bin/env bash
# files: internal/archive/clean.go
# expect: TestUnsauberGrundZaehltUntrackte
# verify: test-go
#
# ADR-0033 Abnahme-Kriterium 2, lesende Haelfte: verengt die Sauberkeits-Pruefung
# des Unterkommandos auf GETRACKTE Dateien — untrackter Bestand zaehlt danach
# nicht mehr.
#
# Warum das ein Waechter und keine Kosmetik ist: der Inhalts-Commit des
# schreibenden Laufs ist der Wave-Self-Close-Punkt, den ein Audit liest. Zaehlt
# die Vorpruefung untrackte Dateien nicht, meldet die Vorschau "der schreibende
# Lauf liefe", waehrend er fremden Inhalt in genau diesen Commit zoege. Nichts
# davon wird von selbst rot: die Zusage lautet "sauberer Arbeitsbaum", und
# gemessen waere danach nur die Haelfte davon.
set -euo pipefail
sed -i 's/^\t\t\tuntrackt++$/\t\t\tuntrackt += 0/' internal/archive/clean.go
