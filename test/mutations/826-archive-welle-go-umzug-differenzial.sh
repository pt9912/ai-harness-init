#!/usr/bin/env bash
# files: internal/archive/scan.go
# expect: TestAnwendenSchreibtDenUmzugsStubAnDerFlachenAdresse
# verify: test-go
#
# DEAKTIVIERT DAS SUCHRAUM-DIFFERENZIAL: SuchraumDifferenzial liefert nil, die
# referenzierenden ADR-Dateien fallen aus dem Kriterium, und der schreibende
# Lauf schreibt keinen Umzugs-Stub — die ADR-Verweise auf die bewegten Slices
# loesen nach dem Altbestand-Lauf an der Alt-Adresse ins Leere, und das Doku-Gate
# bricht dort an der ADR-Zeile rot (ADR-0112 Festlegung 1, Fitness-Tafel).
#
# Der Suchraum SELBST bleibt unveraendert — Haenger, VerweisFund und Nachziehen
# laufen weiter ueber dieselben Mengen; nur der Stub-Schreiber verliert seinen
# Eingang. Das Rot kaeme sonst nirgends her: ein fehlender Stub ist eine LEERE
# Adresse in einem Baum, in dem nach dem Move niemand umschreibt.
set -euo pipefail
sed -i 's/if AusgenommenNachzug(d) {/if false {/' internal/archive/scan.go
