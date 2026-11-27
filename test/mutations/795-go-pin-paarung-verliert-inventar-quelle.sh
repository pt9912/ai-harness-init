#!/usr/bin/env bash
# files: .d-check.yml
# expect: pinsync: das Pin go verliert seine Inventar-Quelle — die Paarung Inventar-Soll gegen die GO_VERSION-Stelle haelt dann nur noch die Pin-Stelle
# verify: test-bats
#
# Entfernt die Quellen-Zeile harness/tools/environment-inventory.txt aus dem Pin go:
# die Paarung Inventar-Soll gegen die Pin-Stelle GO_VERSION (Makefile) ist weg — eine
# Soll-Drift im Inventar gegen den Pin staende ungehaelt. Rot faerbt der Config-Waechter
# test/pinsync-modul-wiring.bats (ohne Docker-Lauf). Der Verhaltens-Zahn ist davor
# gemessen: ein verfaelschter Soll-Wert an GENAU EINER Quelle (Inventar oder Makefile)
# faerbt `make docs-check` mit dem Grund-Code `pinsync-mismatch` rot — als Mutations-Fall
# 796 (Wert). Beleg-Typ: harness/sensors/docs-check.md §Grenze, Modul pinsync.
set -euo pipefail
sed -i '/{file: harness\/tools\/environment-inventory.txt,/d' .d-check.yml
