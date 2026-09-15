#!/usr/bin/env bash
# files: internal/emit/templates/enforce/hooks-install.mk
# expect: TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger
# verify: test-go
#
# HAENGT DIE AKTIVIERUNG AN GATE_CHECKS: `make gates` setzt danach in jedem
# gebootstrappten Repo die lokale Konfiguration.
#
# Das ist die Verwechslung, gegen die das Fragment antritt. Ein Gate ueber einem
# Schritt, der `git config` schreibt, prueft nichts — es faerbt rot, weil ein Klon
# seine Aktivierung noch nicht hat, und gruen, ohne etwas ueber den Baum zu sagen.
# Fall 337 und 343 tragen dieselbe Klasse fuer die Fragmente der Archivierungs- und
# der Lifecycle-Schicht; der Gegenstand ist hier ein dritter.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen werden die
# GATE_CHECKS-Kante und die transitive Hull des `gates`-Ziels ueber allen
# Make-Quellen des Ziels, gelesen aus dem Emit. Ein Lauf von `make gates` im Ziel
# braeuchte den gebootstrappten Baum samt seinem Dokumentenbestand.
set -euo pipefail
sed -i '$a GATE_CHECKS += hooks-install' internal/emit/templates/enforce/hooks-install.mk
