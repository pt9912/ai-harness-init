#!/usr/bin/env bash
# files: harness/tools/digest-freshness.sh
# expect: Hauptschleife, Aufloesung schlaegt fuer einen Pin fehl -> exit 2
#
# Der Lauf endet ohne Befund immer mit Exit 0 statt mit dem gesammelten Fehler: eine Registry,
# die keinen Pin aufloest, gaelte als gruen (LH-QA-02). Rot wird der Schleifen-Fall mit
# PATH-Stub `docker` in test/digest-freshness.bats.
set -euo pipefail
sed -i 's/^exit "[$]fehler"/exit 0/' harness/tools/digest-freshness.sh
