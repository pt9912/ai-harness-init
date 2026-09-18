#!/usr/bin/env bash
# files: internal/emit/templates/enforce/selbstpruefung.sh
# expect: die Selbstpruefung belegt den Ausgang
# verify: full-smoke
#
# NIMMT DER EMITTIERTEN VORLAGE DEN FALLENDEN COMMIT: sie faehrt danach nur noch den
# Commit MIT Kennung und meldet weiter Exit 0. Ein Lauf, der allein den durchgelassenen
# Commit beobachtet, sagt nichts darueber, ob der Traeger ueberhaupt etwas aufhaelt —
# genau die Haelfte, die LH-FA-11 als "beide Ausgaenge in EINEM Lauf" verlangt.
#
# WAS DAS MISST: die Stufe im Voll-E2E liest die AUSGABE der Selbstpruefung, nicht nur
# ihren Exit-Code. Ohne diesen Fall waere die Unterscheidung zwischen "beide Ausgaenge
# gefahren" und "einer gefahren, einer behauptet" am ruhenden Baum nicht sichtbar
# (AGENTS.md 3.6).
#
# WARUM full-smoke DIE SCHMALSTE AUSREICHENDE STUFE IST: gemessen wird die WIRKUNG der
# emittierten Vorlage in einem gebootstrappten Ziel — Klon, Aktivierung, Commit-Versuche.
# Kein Go-Test faehrt `git` gegen ein emittiertes Repo, und die Go-Zaehne der Vorlage
# lesen ihren Text, nicht ihren Lauf. Der Preis eines solchen Falls steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i 's/^for fall in rot gruen; do$/for fall in gruen; do/' internal/emit/templates/enforce/selbstpruefung.sh
