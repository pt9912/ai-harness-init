#!/usr/bin/env bash
# files: .harness/baseline/v6.0.0/templates/AGENTS.template.md
# expect: emit.isRecurring fuehrt genau die Vorlagen mit Platzhalter im Ziel-Pfad
#
# Die Gegenrichtung zu 219: dort driftet der ZIEL-PFAD, hier die WORTSTELLUNG des
# Satzes, der ihn nennt. Der Kopiere-Satz bekommt vor dem Pfad einen zweiten
# Inline-Code-Ausdruck; der Pfad selbst bleibt Zeichen fuer Zeichen derselbe.
#
# ZIEL IST AGENTS.template.md, NICHT MEHR das urspruengliche
# observations.template.md: der v6.0.0-Baum-Tausch hat diese Vorlage nicht bloss
# umbenannt, sondern strukturell ersetzt (fester Kopiere-Satz -> Lege-Satz mit
# ZWEI Platzhaltern, Singleton -> wiederkehrend, ADR-0034/slice-182) — ein blosser
# Pfad-Fix haette den Fall an ein Muster genaeht, das im Nachfolge-Template gar
# nicht mehr vorkommt (kein "Kopiere nach" mehr). AGENTS.template.md traegt
# denselben Kopiere-Satz-mit-festem-Ziel wie vorher observations.template.md und
# ist damit derselbe Fall an einem Ziel, das die Register-Umstellung nicht
# beruehrt — wie schon in 219.
#
# Nach der Mutation ist der erste Backtick-Ausdruck hinter dem Wort "Kopiere" das
# `git mv` und nicht der Pfad. Wer die Anker in ziel_ort lockert, liest ihn:
# die Extraktion ist dann nicht LEER, sondern FALSCH — die OHNE-ZIEL-Zeile bleibt
# aus (es wurde ja etwas gelesen), das gelesene Stueck traegt keinen Platzhalter,
# und die abgeleitete Menge stimmt zufaellig weiter, weil auch der echte Ziel-Pfad
# dieser Vorlage keinen traegt. Ein Waechter ohne die Anker bleibt dabei gruen, und
# zwar fuer jede Vorlage, deren Hinweis so umformuliert wird.
#
# Rot wird es, weil ziel_ort hinter dem Wort "nach" liest und vom gelesenen
# Ausdruck die .md-Endung verlangt: die mutierte Wortstellung liefert keinen
# Treffer, wiederkehrend_real gibt die Zeile OHNE-ZIEL:AGENTS.template.md aus,
# und der diff gegen den isRecurring-Rumpf faellt (selbst gemessen: die Zeile
# "-OHNE-ZIEL:AGENTS.template.md" erscheint im diff, angewendet gegenueber
# unangewendet).
#
# KOPPLUNG beim Baseline-Tausch: der Pfad im `# files:`-Kopf traegt den Tag. Nach
# einem Bump zeigt er ins Leere — der Treiber sichert die gelisteten Dateien VOR
# der Mutation mit tar und laeuft unter `set -euo pipefail`, der Fall endet also
# dort und schreibt kein Ergebnis; daraus macht die Vollstaendigkeits-Schranke in
# merge_report einen Befund. Laut, nicht still.
#
# Der Backtick kommt aus printf statt als Literal: in einfachen Anfuehrungszeichen
# liest shellcheck ihn als Kommando-Substitution (SC2016), und eine
# Inline-Suppression verbietet AGENTS 3.2.
set -euo pipefail
bt="$(printf '\140')"
sed -i "s|Kopiere nach |Kopiere per ${bt}git mv${bt} nach |" \
	.harness/baseline/v6.0.0/templates/AGENTS.template.md
