#!/usr/bin/env bash
# files: .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-slice.template.md
# expect: emit.isRecurring fuehrt genau die Vorlagen mit Platzhalter im Ziel-Pfad
#
# Dieselbe Drift wie 219, an der anderen Satzform. 219 faehrt sie am Kopiere-Satz
# ("Kopiere nach `<pfad>.md`"), dieser Fall am Verbleib-Satz ("… liegen bleibt
# (`<verzeichnis>/`)") — die zwei Archiv-Stubs nennen ihren Ort nur so, und ein Zahn
# an der einen Form sagt ueber die andere nichts.
#
# Der Ort des Stubs verliert seinen Platzhalter: aus done/<welle-id>/ wird done/.
# Danach leitet ziel_ort fuer diese Vorlage "nicht wiederkehrend" ab, waehrend
# emit.isRecurring sie weiter fuehrt — der diff der dritten Achse faellt.
#
# Ohne diesen Waechter faellt das durch jede Masche: der Datei-Bestand ist
# unveraendert, die in-scope-Zahl bleibt unberuehrt, courseSet() bleibt deckungsgleich,
# und die go-test-Stufe sieht .harness/ gar nicht (.dockerignore).
#
# KOPPLUNG beim Baseline-Tausch: der Pfad im `# files:`-Kopf traegt den Tag. Nach
# einem Bump zeigt er ins Leere — der Treiber sichert die gelisteten Dateien VOR
# der Mutation mit tar und laeuft unter `set -euo pipefail`, der Fall endet also
# dort und schreibt kein Ergebnis; daraus macht die Vollstaendigkeits-Schranke in
# merge_report einen Befund. Laut, nicht still.
#
# Das Muster kommt OHNE die umschliessenden Backticks des Verbleib-Satzes aus: der
# Ort steht genau einmal in der Datei — grep -c ueber der Datei unten liefert 1 —,
# und Backticks in einfachen Anfuehrungszeichen liest shellcheck als
# Kommando-Substitution (SC2016); eine Inline-Suppression verbietet AGENTS 3.2.
set -euo pipefail
sed -i 's|docs/plan/planning/done/<welle-id>/|docs/plan/planning/done/|' \
	.harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-slice.template.md
