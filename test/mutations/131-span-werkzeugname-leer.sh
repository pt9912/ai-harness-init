#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestAgentGetsNoArgumentFields
#
# DER WERKZEUG-NAME ERREICHT DIE ZEILE NICHT MEHR: `Span.Tool` wird nicht mehr aus der
# Payload gefuellt. Das FELD bleibt stehen (`"tool":""` — die Pflicht-Zusage aus Fall 130
# haelt), aber es traegt nichts mehr.
#
# WARUM ES DIESEN FALL BRAUCHT: die Zeile `SPEC-022` (`spawned_role`) in
# spec/spezifikation.md §5 legt fest, dass ein `Agent`-Span OHNE `spawned_role` ein Lauf
# mit unbekannter Rolle ist, in den Sammelposten gehoert und am Pflichtfeld `tool`
# unterscheidbar bleibt; `SPEC-082` fuehrt die Erkennbarkeit als Zusage.
# Fall 130 belegt die ANWESENHEIT des Feldes, dieser Fall seinen INHALT: ohne den
# Werkzeug-Namen in der Zeile kann eine Auswertung `Agent`-Spans nicht auswaehlen, und
# die Bilanz je Rolle verliert genau die Laeufe, die sie zaehlen soll.
#
# ROT WERDEN MEHRERE, und das ist hier richtig statt vermeidbar: „der Werkzeug-Name steht
# in der Zeile" ist an drei Stellen zugesagt — `TestAgentGetsNoArgumentFields` und
# `TestFailedAgentCallCapturesNothing` (je `"tool":"Agent"`) sowie
# `TestEmitWritesSpanFromHook` (`"tool":"Bash"`). Eine Mutation, die nur einen davon
# faerbt, gaebe es nicht, ohne die Zusage kuenstlich zu verengen. Gebunden bleibt der Fall
# trotzdem an den benannten Waechter: Bedingung 4 des Treibers verlangt den Namen aus
# der `# expect:`-Zeile in einer `--- FAIL:`-Zeile, nicht irgendein Rot.
set -euo pipefail
sed -i 's@Tool:           p.Tool,@Tool:           "",@' internal/span/emit.go
