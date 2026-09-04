#!/usr/bin/env bash
# files: Makefile
# expect: jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch von main()
# verify: test-bats
#
# HAENGT EINE ZWEITE NENNUNG DES TRAEGERS AN DIESELBE REZEPT-ZEILE, und zwar
# eine, aus der das Namens-Muster nichts zieht: hinter dem Zwischenraum steht
# eine Variablen-Referenz, kein Kleinbuchstabe. Genau diese Form ist im Betrieb
# ungekoppelt — der Name entstuende erst beim Expandieren, und der Fall liest die
# Datei, nicht den expandierten Baum.
#
# ER TRIFFT DIE SELBST-KALIBRIERUNG, NICHT DIE DISPATCH-SCHLEIFE. Die Schleife
# sieht nur, was das Namens-Muster hergibt; was es nicht liest, kann sie nicht
# pruefen. Die Kalibrierung ist die Stelle, die "nicht gelesen" von "gelesen und
# gedeckt" trennt — sie haelt die Zahl der Nennungen gegen die Zahl der Namen.
# Zaehlte eine der beiden Zeilen statt Vorkommen, bliebe der Fall unter genau
# dieser Mutation gruen: eine Zeile mit zwei Nennungen ist eine Zeile.
#
# DIE FORM DES AUSDRUCKS: der Traeger-Pfad steht im Makefile als
# Variablen-Referenz. Anders als in Fall 254 braucht die ERSETZUNG hier selbst
# ein Dollar — eine Klammer-Klasse (`[$]`) taugt dafuer nicht, sie waere im
# Ersetzungsteil drei woertliche Zeichen. Der Ausdruck steht darum in doppelten
# Anfuehrungszeichen mit `\$`; shellcheck liest das als bewusst maskiertes
# Dollar (SC2016 gilt einfachen Anfuehrungszeichen), und eine
# Inline-Unterdrueckung verbietet AGENTS.md §3.2.
set -euo pipefail
sed -i "s,archive-welle \"\$(WELLE)\",& || \$(HOST_BIN) \$(NOTFALL)," Makefile
