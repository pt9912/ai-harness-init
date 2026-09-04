#!/usr/bin/env bash
# files: .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-welle.template.md
# expect: jeder Platzhalter steht in genau der Vorlage, die sein Block fuellt
# verify: test-bats
#
# BENENNT EINEN PLATZHALTER UM, DEN BEIDE VORLAGEN TRAGEN — und zwar in genau
# EINER von ihnen. Der Archiv-Zeiger `done/<welle-id>/archiv.zip` wird im
# Welle-Stub zu `abgelegt/…`; die Slice-Vorlage bleibt unberuehrt.
#
# Das ist die Form, die eine Frage ueber der VEREINIGUNG beider Vorlagen nicht
# sieht: der Platzhalter steht ja noch — nur in der anderen Datei. Der Lauf
# schreibt danach einen Welle-Stub, dessen Zeiger auf einen Pfad zeigt, den es
# nicht gibt, waehrend der Slice-Stub daneben korrekt ist; `FormOK` faengt es
# nicht, denn `archiv.zip` steht weiter im Text. Der Zeiger ist das Einzige, was
# nach der Archivierung vom Volltext uebrig bleibt.
#
# Fall 244 daneben trifft die EXTRAKTION (ein Platzhalter, der nicht auf `>`
# endet); dieser hier trifft die QUANTIFIZIERUNG (ueber welche Datei gefragt
# wird). Zwei verschiedene Waende desselben Waechters.
#
# KOPPLUNG beim Baseline-Tausch: der Pfad im `# files:`-Kopf traegt den Tag.
# Nach einem Bump zeigt er ins Leere, das Mutations-Skript faellt unter
# `set -euo pipefail`, und die Vollstaendigkeits-Schranke des Treibers macht
# daraus einen Befund. Laut, nicht still — dieselbe Kopplung wie in Fall 244.
set -euo pipefail
sed -i 's|done/<welle-id>/archiv\.zip|abgelegt/<welle-id>/archiv.zip|' \
	.harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-welle.template.md
