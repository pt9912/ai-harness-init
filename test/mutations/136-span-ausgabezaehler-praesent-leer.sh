#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestFailedAgentCallCapturesNothing
#
# NIMMT `omitempty` VON `output_tokens` — die Spiegelung von Fall 134 am zweiten der
# vier `usage`-Zaehler. Danach steht `"output_tokens":null` in JEDER Zeile: im
# fehlgeschlagenen `Agent`-Aufruf, in jedem `Bash`-Span, ueberall.
#
# ES IST KEINE KOPIE VON 134, SONDERN DIE AUFLOESUNG EINES GEMESSENEN LOCHS
# (Review-Befund MEDIUM-1 vom 2026-07-30). `TestFailedAgentCallCapturesNothing` prueft
# den Fehlschlag-Span gegen die NEUN Werte aus spec/spezifikation.md §5 — bis zum
# 2026-07-30 nannte seine `mustNotContain`-Liste aber nur ACHT davon. `input_tokens`
# deckt per Teilstring zusaetzlich die zwei Cache-Zaehler ab; `output_tokens` deckt
# NICHTS davon ab und stand repo-weit in keiner Negativ-Pruefung. Gemessen statt
# geschlossen: mit `json:"output_tokens"` blieb `make test-go` bei Exit 0 mit NULL
# `--- FAIL:`-Zeilen, und ein reiner `Bash`-Span trug danach
# `"output_tokens":null` (beides am 2026-07-30 gefahren, in isolierter Kopie). Der
# Waechter nennt das Feld jetzt; DIESER Fall haelt den Eintrag am Leben: wer ihn aus
# der Liste streicht, bekommt hier kein Rot mehr, und `make mutate` meldet Befund —
# gemessen am 2026-07-30 in beide Richtungen: mit Eintrag "ok", ohne ihn BEFUND
# ("make test-go blieb GRUEN — ... hat keine Zaehne mehr").
#
# WARUM DAS ZAEHLT und nicht Formalie ist: die Draht-Form traegt die Lesevorschrift aus
# spec/spezifikation.md §5 — ein Wert, der DASTEHT, behauptet eine Messung. `"output_tokens":null` in
# jedem `Bash`-Span erzaehlt der Auswertung von slice-066 einen Zaehler, den nie jemand
# erhoben hat. Es ist die Fehlerform, gegen die ADR-0011 Folgepflicht 4 die
# Folgenummern eingefuehrt hat, eine Ebene weiter innen.
#
# ROT WIRD GENAU EINER — ausgezaehlt ueber ALLE `--- FAIL:`-Zeilen des Laufs, nicht am
# erwarteten Namen abgelesen (2026-07-30, isolierte Kopie): die uebrigen
# Waechter dieser Flaeche nennen `output_tokens` entweder gar nicht
# (TestAgentGetsNoArgumentFields, TestUnlistedResponseKeyStaysOut) oder nur in ihrer
# Gegenprobe mit MESSWERT (`"output_tokens":22` in TestNoResponseFreetextReachesSpan) —
# den beruehrt ein fehlendes `omitempty` nicht. `"output_tokens":null` ist ausserdem
# Teilstring von keiner der uebrigen Negativ-Zusicherungen; `canReadOutputFile` in
# TestUnlistedResponseKeyStaysOut sieht nur aehnlich aus.
#
# DER ANKER TRIFFT NUR DIESES FELD: `json:"output_tokens,omitempty"` steht repo-weit
# genau einmal (internal/span/response.go, `OutputTokens`) — die zwei Cache-Zaehler
# tragen eigene Namen, `input_tokens` beginnt hinter dem `json:"` anders.
set -euo pipefail
sed -i 's@json:"output_tokens,omitempty"@json:"output_tokens"@' internal/span/response.go
