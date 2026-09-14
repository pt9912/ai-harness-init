#!/usr/bin/env bash
# files: .harness/baseline/*/templates/docs/plan/planning/archiv-stub-welle.template.md
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
# `# files:` NENNT DEN TAG NICHT MEHR: der Pfad wird ueber
# `.harness/baseline/*/templates/...` gegen den EINEN vendored Baum ENTDECKT
# (harness/tools/mutate.sh, resolve_file_spec) statt ihn zu nennen — ein
# Baseline-Sprung aendert daran nichts, solange die Vorlage im neuen Satz
# unter demselben relativen Pfad liegt. Loest die Angabe NICHT auf genau eine
# Datei auf (kein Tag-Verzeichnis, mehr als eines), bricht der Treiber laut ab
# und nennt diesen Fall — vor jedem Fall-Lauf in mutation_targets bzw.
# target_fingerprint (harness/sensors/mutate.md §Grenze), wie in Fall 244.
set -euo pipefail
sed -i 's|done/<welle-id>/archiv\.zip|abgelegt/<welle-id>/archiv.zip|' \
	.harness/baseline/*/templates/docs/plan/planning/archiv-stub-welle.template.md
