#!/usr/bin/env bash
# files: .harness/baseline/*/templates/docs/plan/planning/archiv-stub-slice.template.md
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
# `# files:` ENTDECKT DAS TAG-VERZEICHNIS: der Pfad wird ueber
# `.harness/baseline/*/templates/...` gegen den EINEN vendored Baum ENTDECKT
# (harness/tools/mutate.sh, resolve_file_spec) statt ihn zu nennen — ein
# Baseline-Sprung aendert daran nichts, solange die Vorlage im neuen Satz
# unter demselben relativen Pfad liegt. Loest die Angabe NICHT auf genau eine
# Datei auf (kein Tag-Verzeichnis, mehr als eines), bricht der Treiber laut ab
# und nennt diesen Fall — vor jedem Fall-Lauf in mutation_targets bzw.
# target_fingerprint (harness/sensors/mutate.md §Grenze), wie in Fall 219.
#
# Das Muster kommt OHNE die umschliessenden Backticks des Verbleib-Satzes aus: der
# Ort steht genau einmal in der Datei — grep -c ueber der Datei unten liefert 1 —,
# und Backticks in einfachen Anfuehrungszeichen liest shellcheck als
# Kommando-Substitution (SC2016); eine Inline-Suppression verbietet AGENTS 3.2.
set -euo pipefail
sed -i 's|docs/plan/planning/done/<welle-id>/|docs/plan/planning/done/|' \
	.harness/baseline/*/templates/docs/plan/planning/archiv-stub-slice.template.md
