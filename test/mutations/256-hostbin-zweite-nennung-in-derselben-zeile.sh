#!/usr/bin/env bash
# files: Makefile
# expect: jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch von main()
# verify: test-bats
#
# HAENGT EINE ZWEITE NENNUNG DES TRAEGERS AN DIESELBE REZEPT-ZEILE, und zwar
# eine, aus der das Namens-Muster nichts zieht: direkt hinter dem Zwischenraum
# steht ein doppeltes Anfuehrungszeichen — eines der drei Zeichen, an denen das
# Muster ein Wort enden laesst. Genau diese Form ist im Betrieb ungekoppelt: der
# Name entstuende erst beim Expandieren, und der Fall liest die Datei, nicht den
# expandierten Baum.
#
# ER TRIFFT DIE SELBST-KALIBRIERUNG, NICHT DIE DISPATCH-SCHLEIFE. Die Schleife
# sieht nur, was das Namens-Muster hergibt; was es nicht liest, kann sie nicht
# pruefen. Die Kalibrierung ist die Stelle, die "nicht gelesen" von "gelesen und
# gedeckt" trennt — sie haelt die Zahl der Nennungen gegen die Zahl der Namen
# und meldet hier eine Nennung MEHR als Namen ("aus N Nennung(en) in der
# Makefile sind N-1 Name(n) gewonnen"; die Zahlen wachsen mit dem Makefile).
#
# ER IST DAS GEGENBEISPIEL ZUR ZAEHLGROESSE DER KALIBRIERUNG. Zaehlte
# `nennungen` Zeilen statt Vorkommen, waeren die zwei Nennungen dieser einen
# Zeile als eine gezaehlt: die Kalibrierung bliebe ausgeglichen, die Schleife
# liefe ueber lauter gueltige Namen, und der Fall bliebe unter genau dieser
# Mutation gruen — waehrend die zweite Nennung ungekoppelt danebensteht.
#
# DIE FORM DES AUSDRUCKS: der Traeger-Pfad steht im Makefile als
# Variablen-Referenz, und die ERSETZUNG braucht hier selbst ein Dollar und zwei
# Anfuehrungszeichen. Anders als in Fall 254 taugt eine Klammer-Klasse (`[$]`)
# dafuer nicht — sie waere im Ersetzungsteil drei woertliche Zeichen. Der
# Ausdruck steht darum in doppelten Anfuehrungszeichen mit `\$` und `\"`; das
# liest shellcheck als bewusst maskiertes Dollar (SC2016 gilt einfachen
# Anfuehrungszeichen), und eine Inline-Unterdrueckung verbietet AGENTS.md §3.2.
set -euo pipefail
sed -i "s,archive-welle \"\$(WELLE)\",& || \$(HOST_BIN) \"\$(NOTFALL)\"," Makefile
