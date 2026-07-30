#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestAgentGetsNoArgumentFields
#
# `Agent` WIRD AUF EINE GATTUNGSZEILE ABGEBILDET: die Ableitung behandelt es wie ein
# KOMMANDO-Werkzeug. Danach traegt ein `Agent`-Span `program` und `argc` — abgeleitet aus
# einem `tool_input`, aus dem laut Plan NICHTS den Span erreicht.
#
# DAS IST B2 des Architect-Verdikts vom 2026-07-30
# (docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md §6): `Agent` ist
# namentlich gelistet, aber auf KEINE der drei Gattungen (Datei-Lesen, Datei-Schreiben,
# Kommando) abgebildet. Die Gattungen sind der Weg, auf dem ADR-0011 Festlegung 2
# ueberhaupt Argumente in den Span laesst; `Agent` darf ihn nicht nehmen, weil in seinem
# `tool_input` `prompt` und `description` liegen.
#
# WARUM ES DIESEN FALL BRAUCHT: die Zusicherung steht seit dem 2026-07-30 im Waechter
# (`s.Path != "" || s.Program != "" || s.Argc != nil || …`) und hatte keinen Dauer-Zahn.
# Fall 131 nennt denselben Waechter, bindet aber seine Gegenprobe `"tool":"Agent"`, und
# Fall 132 seine B1-Zusicherung — B2 durfte weiter lautlos verschwinden. Dieselbe Klasse
# wie Verifier-Befund V-1, nur an der dritten Zusicherung desselben Waechters. Ein Zahn
# je Zusicherung ist hier kein Luxus: die drei messen drei verschiedene Achsen (Werkzeug-
# Name, Ergebnis-Herkunft, Argument-Ableitung).
#
# WARUM DIE KOMMANDO- UND NICHT DIE DATEI-GATTUNG: mit `classFileRead` faellt der
# Waechter schon an seinem `mustNotContain` (der Pfad `/etc/shadow` aus dem `tool_input`
# stuende dann in der Zeile) — die STRUKT-Pruefung darunter wuerde nie erreicht, und
# genau sie ist B2. Ueber die Kommando-Gattung entstehen `"program":"gh"` und `"argc":4`;
# beide stehen auf keiner `mustNotContain`-Liste, der Waechter laeuft bis zur
# Strukt-Pruefung durch und faellt dort. So bindet dieser Fall die Zusicherung, die er
# tragen soll — nicht eine davor.
#
# `"argc":4` UND NICHT 5 (Review-Befund LOW-1 vom 2026-07-30): `argc` zaehlt ARGUMENTE,
# nicht Felder — `commandProgram` liefert `len(fields) - i - 1`, und die Kommandozeile
# des Waechters (`gh auth login --with-token TOKEN-iii999`) hat fuenf Felder. Dieselbe
# Semantik misst TestCommandProgramSkipsAssignments bei jedem `make test-go`
# (`"ls -l /tmp"` -> argc 2). Der Kopf sagte bis dahin 5 zu — siebte Instanz der
# Familie "Zahl behauptet statt abgezaehlt" in diesem Slice.
#
# ROT WIRD GENAU EINER: die uebrigen `Agent`-Payloads dieser Flaeche fuehren kein
# `command` in ihrem `tool_input`, und `commandProgram("")` liefert nichts — sie bleiben
# unveraendert. Die Werkzeuge der uebrigen Gattungen ruehrt die Mutation nicht an.
set -euo pipefail
sed -i 's@^\tcase classCommand:$@\tcase classCommand, classAgent:@' internal/span/span.go
