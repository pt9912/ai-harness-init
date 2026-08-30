#!/usr/bin/env bash
# files: .harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md
# expect: emit.isRecurring fuehrt genau die Vorlagen mit Platzhalter im Ziel-Pfad
#
# Die Gegenrichtung zu 215-218: dort wandert die AUFZAEHLUNG, hier die QUELLE. Der
# Template-Hinweis des Beobachtungs-Registers bekommt einen Platzhalter in den
# Ziel-Pfad — genau die Form, an der emit.isRecurring "wiederkehrend" festmacht.
# Die Vorlage ist danach nach der eigenen Definition des Emitters wiederkehrend und
# steht trotzdem nicht in seiner Liste.
#
# Ohne diesen Waechter faellt das durch jede Masche: der Datei-Bestand ist
# unveraendert, die in-scope-Zahl bleibt 21, courseSet() bleibt deckungsgleich, und
# die go-test-Stufe sieht .harness/ gar nicht (.dockerignore).
# Der Emitter liefe still gegen seine eigene Definition — die Klasse "Baseline
# gebumpt, Klassifikation nicht nachgezogen", deren strukturelle Abschaffung der
# inScope-Kommentar zusagt.
#
# KOPPLUNG beim Baseline-Tausch: der Pfad im `# files:`-Kopf traegt den Tag. Nach
# einem Bump zeigt er ins Leere — der Treiber sichert die gelisteten Dateien VOR
# der Mutation mit tar und laeuft unter `set -euo pipefail`, der Fall endet also
# dort und schreibt kein Ergebnis; daraus macht die Vollstaendigkeits-Schranke in
# merge_report einen Befund. Laut, nicht still.
#
# Das Muster kommt OHNE die umschliessenden Backticks des Kopiere-Satzes aus: der
# Pfad steht genau einmal in der Datei — grep -c 'observations\.md' ueber der Datei
# unten liefert 1 —, und Backticks in einfachen Anfuehrungszeichen liest shellcheck
# als Kommando-Substitution (SC2016); eine Inline-Suppression verbietet AGENTS 3.2.
set -euo pipefail
sed -i 's|docs/plan/planning/observations\.md|docs/plan/planning/<bereich>/observations.md|' \
	.harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md
