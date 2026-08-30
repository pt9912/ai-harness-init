#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: baseline-verify haengt als erster an der Kante
#
# Die erste Voraussetzung wandert ans Ende der Kante: `record-gates: <a> <b> … ## …` ->
# `record-gates: <b> … <a> ## …`. Der Bestand der Liste bleibt unveraendert, nur ihre
# Reihenfolge kippt — und mit ihr die Zusage neben der Kante, dass baseline-verify als
# ERSTER laeuft. Steht die vendored Baseline nicht, urteilen die Folge-Gates ueber einen
# Baum, dessen Regelwerk niemand geprueft hat; ihr Gruen sagt dann nichts.
#
# Serielles `make` baut die Voraussetzungen in Listen-Reihenfolge ab, die Mutation
# aendert also wirklich den Lauf und nicht nur den Text. Das Muster nennt keinen
# Check-Namen: es nimmt, was zuerst steht, und haengt es hinten an.
set -euo pipefail
sed -i 's/^record-gates: \([^ ]*\) \([^#]*\)##/record-gates: \2\1 ##/' Makefile
