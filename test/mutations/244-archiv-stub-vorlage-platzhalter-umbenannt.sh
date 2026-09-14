#!/usr/bin/env bash
# files: .harness/baseline/*/templates/docs/plan/planning/archiv-stub-welle.template.md
# expect: jeder Platzhalter steht in genau der Vorlage, die sein Block fuellt
# verify: test-bats
#
# BENENNT EINEN PLATZHALTER DER VENDORED VORLAGE UM — die Richtung, aus der eine
# Baseline-Form-Aenderung kommt. Der Code ersetzt danach `<welle-id>-results.md`
# in einer Vorlage, die den Platzhalter nicht mehr traegt.
#
# Die Folge ist still: `<welle-id>` ist Teilzeichenkette des umbenannten Restes,
# und weil die einfache Ersetzung als LETZTE laeuft, faengt sie ihn auf. Der
# Welle-Stub traegt danach `**Ergebnisnotiz:** welle-NN-ergebnisse.md` OHNE Link
# — genau der Zustand, den der Datei-Kopf des Waechters ausschliessen soll.
#
# Getroffen ist die EXTRAKTION des Waechters, nicht die Vorlage, die der Fall
# anfasst: `<welle-id>-results.md` endet nicht auf `>`, und ein Muster, das den
# Platzhalter an seinem letzten Zeichen erkennt, sieht ihn nicht. Der Fall haelt
# damit die Aussage des Test-Namens — „jeder Platzhalter" — gegen die Menge, die
# der Code wirklich ersetzt.
#
# `# files:` ENTDECKT DAS TAG-VERZEICHNIS: der Pfad wird ueber
# `.harness/baseline/*/templates/...` gegen den EINEN vendored Baum ENTDECKT
# (harness/tools/mutate.sh, resolve_file_spec) statt ihn zu nennen — ein
# Baseline-Sprung aendert daran nichts, solange die Vorlage im neuen Satz
# unter demselben relativen Pfad liegt. Loest die Angabe NICHT auf genau eine
# Datei auf (kein Tag-Verzeichnis, mehr als eines), bricht der Treiber laut ab
# und nennt diesen Fall — vor jedem Fall-Lauf in mutation_targets bzw.
# target_fingerprint (harness/sensors/mutate.md §Grenze), wie in Fall 219.
set -euo pipefail
sed -i 's|<welle-id>-results\.md|<welle-id>-ergebnisse.md|' \
	.harness/baseline/*/templates/docs/plan/planning/archiv-stub-welle.template.md
