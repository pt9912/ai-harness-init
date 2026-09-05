#!/usr/bin/env bash
# files: .harness/baseline/v6.0.0/templates/AGENTS.template.md
# expect: emit.isRecurring fuehrt genau die Vorlagen mit Platzhalter im Ziel-Pfad
#
# Die Gegenrichtung zu 215-218: dort wandert die AUFZAEHLUNG, hier die QUELLE. Der
# Kopiere-Satz eines SINGLETON-Templates bekommt einen Platzhalter in den
# Ziel-Pfad -- genau die Form, an der emit.isRecurring "wiederkehrend" festmacht.
# Die Vorlage ist danach nach der eigenen Definition des Emitters wiederkehrend und
# steht trotzdem nicht in seiner Liste.
#
# ZIEL IST AGENTS.template.md, NICHT MEHR das urspruengliche
# observations.template.md: der v6.0.0-Baum-Tausch hat diese Vorlage nicht bloss
# umbenannt, sondern strukturell ersetzt (fester Kopiere-Satz -> Lege-Satz mit
# ZWEI Platzhaltern, Singleton -> wiederkehrend, ADR-0034/slice-182). Ein blosser
# Pfad-Fix haette den Fall an ein Muster genaeht, das im Nachfolge-Template gar
# nicht mehr vorkommt (kein "Kopiere nach", kein fester `.md`-Pfad). AGENTS.template.md
# traegt denselben Kopiere-Satz-mit-festem-Ziel wie vorher observations.template.md
# und ist damit derselbe Fall an einem Ziel, das die Register-Umstellung nicht
# beruehrt.
#
# Ohne diesen Waechter faellt das durch jede Masche: der Datei-Bestand ist
# unveraendert, die in-scope-Zahl bleibt unberuehrt, courseSet() bleibt deckungsgleich, und
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
# Die Zeile "Kopiere nach `AGENTS.md` deines Repos" traegt AGENTS.md zweimal —
# einmal davor in "Repo-Root-`AGENTS.md`", einmal dahinter als Ziel. Der sed-Anker
# adressiert ueber die (einzige) Zeile mit "Kopiere nach" und trifft darin gezielt
# das ZWEITE Vorkommen ueber das Occurrence-Flag, statt Backticks ins Muster
# aufzunehmen: Backticks in einfachen Anfuehrungszeichen liest shellcheck als
# Kommando-Substitution (SC2016), eine Inline-Suppression verbietet AGENTS 3.2.
set -euo pipefail
sed -i '/Kopiere nach/ s/AGENTS\.md/<bereich>\/AGENTS.md/2' \
	.harness/baseline/v6.0.0/templates/AGENTS.template.md
