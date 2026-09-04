#!/usr/bin/env bash
# files: Makefile
# expect: jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch von main()
# verify: test-bats
#
# VERTIPPT DEN NAMEN IM BEDIEN-EINSTIEG: das Ziel `archive-welle` gibt dem
# Traeger danach `archive-well`. Ein Dateipfad in derselben Position waere laut
# gescheitert — ein Unterkommando-Name scheitert leise, denn der Traeger nimmt
# jede Zeichenkette entgegen und entscheidet erst drinnen, was sie bedeutet.
#
# Das Literal steht an zwei Stellen und nichts ausser diesem Fall haelt sie
# aneinander: `make comment-claims` hat den Makefile dauerhaft ausserhalb seines
# Pruefbereichs, und keine Go-Stufe liest ihn. Ohne den Fall bleibt die
# Verstimmung bis zum naechsten Bedien-Versuch unsichtbar.
#
# DIE FORM DES AUSDRUCKS: der Traeger-Pfad steht im Makefile als
# Variablen-Referenz, und ihr Dollar bleibt hier in einer Klammer-Klasse
# (`[$]`) statt vor der Klammer — sonst laese shellcheck ihn als
# Kommando-Substitution (SC2016), und eine Inline-Unterdrueckung verbietet
# AGENTS.md §3.2. Ersetzt wird darum ueber eine Gruppe: der Praefix wandert
# unveraendert zurueck, geaendert wird allein der Name dahinter.
set -euo pipefail
sed -i 's|^\(\t@[$](HOST_BIN) \)archive-welle |\1archive-well |' Makefile
