#!/usr/bin/env bash
# files: Makefile
# expect: release-host: der Formel-Teillauf meldet den Formel-Entfall im DEST
# verify: test-bats
#
# ENTHEMMT DIE FORMEL-TEILLAUf-MELDUNG: der else-Zweig des Formel-Griffs,
# der den Formel-Entfall im DEST nennt ("Teillauf ohne die vier
# brew-Plattformen"), trift ein Muster, das nicht mehr liegt — der Teillauf
# endet still ohne Formel, ohne ihren Entfall zu nennen.
#
# Waechter ist der Fall "release-host: der Formel-Teillauf meldet den
# Formel-Entfall im DEST" in test/release-host-bau.bats: er faehrt einen
# Ein-Plattform-Lauf mit gesetzter Fassung und haelt Meldung UND
# fehlende Formel-Datei — mit entzogener Meldung faellt der Meldungs-grep.
set -euo pipefail
sed -i 's@Teillauf ohne die vier brew-Plattformen@Teillauf ohnx die vier brew-Plattformen@' Makefile
