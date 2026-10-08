#!/usr/bin/env bash
# files: internal/emit/templates/enforce/hooks-install.mk
# expect: aber keine Zeile des Ziels nennt .githooks/commit-msg
# verify: full-smoke
#
# NIMMT DEM EMITTIERTEN AKTIVIERUNGS-FRAGMENT DIE TRAEGER-PRUEFUNG: die `test -f`-Zeile,
# die bei fehlender Traeger-Datei mit einer Zeile `hooks-install: <pfad> liegt nicht …`
# abbricht, bevor `git config core.hooksPath` einen Pfad setzt, unter dem nichts liegt
# (LH-QA-01).
#
# WAS DAS MISST: Fall (b) der full-smoke-Stufe "Aktivierung im Klon". Ohne die Zeile
# bricht das Rezept bei fehlender Datei erst an `chmod +x` ab — Exit != 0 und
# core.hooksPath bleibt leer, aber keine Zeile des Ziels nennt den Fall; die Stufe liest
# genau das und faellt. Ueber einem Verzeichnis an der Stelle der Datei ginge die
# Aktivierung durch (`test -x` ist dort wahr) — das deckt Fall (c) derselben Stufe.
#
# WARUM full-smoke DIE SCHMALSTE AUSREICHENDE STUFE IST: gefahren wird die Kette
# Ziel -> make -> Rezept -> git config in einem gebootstrappten Klon. Das gepinnte
# bats-Image fuehrt kein git, und ein Zahn ueber dem TEXT des Rezepts laege eine Ebene
# zu hoch (AGENTS.md 3.6). Der Preis eines solchen Falls steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i '/^\t@test -f ".(HOOKS_DIR)\/commit-msg" ||/d' internal/emit/templates/enforce/hooks-install.mk
