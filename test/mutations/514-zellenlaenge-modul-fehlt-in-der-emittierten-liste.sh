#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: FEHLER — Zellenlaenge-Gegenbeispiel (Vertrag)
# verify: full-smoke
#
# NIMMT DER EMITTIERTEN KONFIGURATION DAS MODUL structure aus der modules:-Liste, der
# Block am Ende der Datei bleibt stehen. Die Stufe zellenlaenge_im_ziel (full-smoke.sh) faehrt
# den gruenen Start am frisch emittierten Ziel und je Spalte einen Zellsatz ueber der Grenze;
# ohne das Modul bleibt der Zellsatz gruen, und die Stufe endet mit FEHLER.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, spans, structure, targets\]$/modules: [links, anchors, ids, matrix, spans, targets]/' internal/emit/templates/d-check.yml
