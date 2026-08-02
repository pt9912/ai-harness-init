#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestAgentGetsNoArgumentFields
#
# DER WERKZEUG-NAME ERREICHT DIE ZEILE NICHT MEHR: `Span.Tool` wird nicht mehr aus der
# Payload gefuellt. Das FELD bleibt stehen (`"tool":""` — die Pflicht-Zusage aus Fall 130
# haelt), aber es traegt nichts mehr.
#
# WARUM ES DIESEN FALL BRAUCHT: die Lesevorschrift zu `spawned_role` in
# spec/spezifikation.md §5 sagt, ein `Agent`-Span OHNE `spawned_role` sei ein Lauf
# mit unbekannter Rolle und gehoere in den Sammelposten — „unterscheidbar bleibt es am
# Pflichtfeld `tool`". Diese Unterscheidbarkeit ist die zweite Haelfte der Voraussetzung,
# die MR-018 bis zum 2026-07-30 dem Zahn 110 zuschrieb (Review-Befund R2-MEDIUM-1).
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
