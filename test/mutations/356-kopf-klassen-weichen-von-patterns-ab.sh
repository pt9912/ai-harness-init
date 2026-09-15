#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: kopplung: die Klassen-Aufzaehlung im Kopf ist die der Zeile patterns=
# verify: test-bats
#
# DIE KLASSEN-AUFZAEHLUNG IM KOPF VERLIERT EINE KLASSE, die Zeile `patterns=` behaelt
# sie: der Kopf nennt danach drei Kennungs-Klassen, der Pruefer setzt vier durch, und
# beide sind gruen — die Aufzaehlung im Kopf ist Prosa neben der ausfuehrenden Zeile.
#
# DIE ZWEITE AUFZAEHLUNG DERSELBEN MENGE IN DERSELBEN DATEI, eine Ebene hoeher als die
# Fehlermeldung: sie beschreibt, was der Pruefer annimmt, und sie folgt `patterns=` nicht.
set -euo pipefail
sed -i 's@{ADR-, LH-, MR-, slice-}@{ADR-, LH-, MR-}@' internal/emit/templates/enforce/commit-msg-traceability.sh
