#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: rot: eine Message ohne Kennung wird abgelehnt
# verify: test-bats
#
# NIMMT DER EMITTIERTEN PRUEFUNG DIE KENNUNGS-PRUEFUNG: das Muster wird zu ".*", jede
# Zeile gilt damit als Kennung, und der Traeger laesst jede Message durch. Der Hook
# bleibt ansonsten heil — er laeuft, er meldet nichts, er endet mit 0.
#
# DIE EMITTIERTE FASSUNG DES PRUEFERS, nicht die dieses Repos: sie ist die, die ein
# gebootstrapptes Ziel bekommt, und der Zahn muss die Stelle treffen, die dort laeuft.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen wird das Urteil ueber
# eine Message-Datei — bash und coreutils, kein git, kein Docker, kein Zielrepo. Ein
# `make full-smoke` belegte zusaetzlich den Aufruf DURCH git, kostet aber den vollen
# E2E-Lauf ueber drei Bootstrap-Varianten.
set -euo pipefail
sed -i -E 's@^patterns=.*$@patterns=".*"@' internal/emit/templates/enforce/commit-msg-traceability.sh
