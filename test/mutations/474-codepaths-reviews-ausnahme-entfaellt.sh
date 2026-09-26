#!/usr/bin/env bash
# files: .d-check.yml
# expect: codepaths fuehrt die Zeile exempt-paths mit docs/reviews/** — die Bedingung der Form-Regel des Nachzugs (ADR-0070)
# verify: test-bats
#
# NIMMT codepaths DIE AUSNAHME FUER docs/reviews/**: die Zeile unter `codepaths:` faellt weg,
# die Form-Regel des Verweis-Nachzugs (ADR-0070) besteht weiter. Das Doku-Gate prueft dann jeden
# Pfad-Span in den Review-Reports — die Regel, die genau diese Pruefung als nicht vorhanden
# voraussetzt, hat ihre Grundlage verloren.
#
# WAS DAS MISST: die Bindung des Tests an den Block `codepaths:`. Die Datei traegt `docs/reviews/**`
# in weiteren `exempt-paths`-Zeilen (unter `ids` und `matrix`); ein Test, der die ganze Datei
# absucht, bliebe bei dieser Mutation gruen. Der Fall faerbt nur, solange der Test auf den Block
# schaut.
#
# Der Anker steht genau einmal in .d-check.yml, mit zwei Zeichen Einrueckung
# (grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml -> 1).
set -euo pipefail
sed -i '\~^  exempt-paths: \["docs/reviews/\*\*"\]$~d' .d-check.yml
