#!/usr/bin/env bash
# files: .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-welle.template.md
# expect: jeder Platzhalter der Stub-Erzeugung steht in einer der zwei Vorlagen
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
# KOPPLUNG beim Baseline-Tausch: der Pfad im `# files:`-Kopf traegt den Tag.
# Nach einem Bump zeigt er ins Leere, das Mutations-Skript faellt unter
# `set -euo pipefail`, und die Vollstaendigkeits-Schranke des Treibers macht
# daraus einen Befund. Laut, nicht still — dieselbe Kopplung wie in Fall 219.
set -euo pipefail
sed -i 's|<welle-id>-results\.md|<welle-id>-ergebnisse.md|' \
	.harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-welle.template.md
