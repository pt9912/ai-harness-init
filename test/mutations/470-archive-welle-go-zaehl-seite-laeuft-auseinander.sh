#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenUnterReviewsSchreibtNurDieLinkForm
# verify: test-go
#
# LAESST DIE ZAEHL-SEITE UNTER docs/reviews/ BEI DER ALTEN REGEL: fundIn zaehlt
# dort die Praefix-Form in jeder Form (ZaehlePraefix), waehrend ersetzeIn nur die
# Link-Form schreibt. Die Vorschau nennt Verweise, die der Nachzug nicht schreibt —
# ihr Blast-Radius ist groesser als das, was der Lauf anfasst.
#
# WAS DAS MISST: der Fall vergleicht ueber DERSELBEN Datei die Zahl von
# VerweisFund mit der von Nachziehen und mit der erwarteten Link-Zahl. Der
# Inhalts-Vergleich allein bliebe bei dieser Mutation gruen, weil die
# Ersetz-Seite unberuehrt ist.
#
# Der Anker steht genau einmal in refs.go, in fundIn
# (grep -cF 'zaehlePraefix = ZaehlePraefixLink' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~zaehlePraefix = ZaehlePraefixLink~zaehlePraefix = ZaehlePraefix~' internal/archive/refs.go
