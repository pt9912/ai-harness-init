#!/usr/bin/env bash
# files: .harness/baseline/*/templates/AGENTS.template.md
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
# `# files:` ENTDECKT DAS TAG-VERZEICHNIS: der Pfad wird ueber
# `.harness/baseline/*/templates/...` gegen den EINEN vendored Baum ENTDECKT
# (harness/tools/mutate.sh, resolve_file_spec) statt ihn zu nennen — ein
# Baseline-Sprung aendert daran nichts, solange die Vorlage im neuen Satz
# unter demselben relativen Pfad liegt. Loest die Angabe NICHT auf genau eine
# Datei auf (kein Tag-Verzeichnis, mehr als eines), bricht der Treiber laut ab
# und nennt diesen Fall — vor jedem Fall-Lauf in mutation_targets bzw.
# target_fingerprint (harness/sensors/mutate.md §Grenze).
#
# Die Zeile "Kopiere nach `AGENTS.md` deines Repos" traegt AGENTS.md zweimal —
# einmal davor in "Repo-Root-`AGENTS.md`", einmal dahinter als Ziel. Der sed-Anker
# adressiert ueber die (einzige) Zeile mit "Kopiere nach" und trifft darin gezielt
# das ZWEITE Vorkommen ueber das Occurrence-Flag, statt Backticks ins Muster
# aufzunehmen: Backticks in einfachen Anfuehrungszeichen liest shellcheck als
# Kommando-Substitution (SC2016), eine Inline-Suppression verbietet AGENTS 3.2.
set -euo pipefail
sed -i '/Kopiere nach/ s/AGENTS\.md/<bereich>\/AGENTS.md/2' \
	.harness/baseline/*/templates/AGENTS.template.md
