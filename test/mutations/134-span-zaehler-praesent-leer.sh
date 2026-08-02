#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestFailedAgentCallCapturesNothing
#
# NIMMT `omitempty` VON `input_tokens`. Danach steht der Zaehler in JEDER Zeile — auch
# dort, wo nie gemessen wurde: `"input_tokens":null` in einem fehlgeschlagenen
# `Agent`-Aufruf, in jedem `Bash`-Span, ueberall. Das ist der HALBE Span, den
# `TestFailedAgentCallCapturesNothing` ausschliesst.
#
# ES IST DIE SPIEGELUNG VON FALL 110/111/130, nicht ihre Kopie: dort setzt die Mutation
# ein `omitempty` an ein PFLICHT-Feld und laesst es lautlos verschwinden; hier nimmt sie
# es von einem OPTIONALEN und laesst es lautlos erscheinen. Beide Draht-Formen sind in
# spec/spezifikation.md §5 festgelegt, und beide tragen dieselbe Lesevorschrift —
# der Unterschied zwischen „unbekannt" und „nicht vorhanden". Ein anwesender Zaehler
# ohne Messung dreht sie um: der Auswerter sieht eine Messung, wo keine stattfand, und
# genau das ist die Fehlerform, gegen die ADR-0011 Folgepflicht 4 die Folgenummern
# eingefuehrt hat.
#
# WARUM ES DIESEN FALL BRAUCHT: `TestFailedAgentCallCapturesNothing` hatte bis zum
# 2026-07-30 KEINEN Fall in test/mutations/ und war damit nach AGENTS.md §3.6 unbewacht
# (Verifier-Befund V-1, zweiter Teil). Der Fehlschlag ist zugleich der Zustand, den die
# Erfassung ohne Sonderregel tragen soll — bei unbekanntem Agenten-Typ fehlt
# `tool_response` GANZ (gemessen, slice-060 §3 Zeile 4). Was hier bricht, bricht also
# nicht an einer Ausnahme, sondern an der Draht-Form.
#
# ROT WIRD GENAU EINER, und warum ausgerechnet `input_tokens` die Wahl ist: es ist das
# einzige der neun Felder, dessen Anwesenheit NUR dieser Waechter ausschliesst. Der
# naheliegendere Griff nach `spawned_role` faerbte zusaetzlich
# `TestAgentGetsNoArgumentFields` (auch dessen `mustNotContain` nennt es) — zwei
# Waechter, und „134 rot" hiesse nicht mehr eindeutig „der Fehlschlag bleibt leer" (die
# Lehre aus Review-Befund R2-MEDIUM-4). Die Gegenproben von
# `TestNoResponseFreetextReachesSpan` und `TestUnlistedResponseKeyStaysOut` verlangen
# `"input_tokens":11` und bleiben unberuehrt, weil der Wert dort gemessen IST.
#
# DER ANKER TRIFFT NUR DIESES FELD: `json:"input_tokens,omitempty"` steht so nur an
# `InputTokens` — die zwei Cache-Zaehler tragen `json:"cache_creation_input_tokens,…"`
# bzw. `json:"cache_read_input_tokens,…"` und beginnen damit hinter dem `json:"`
# anders.
set -euo pipefail
sed -i 's@json:"input_tokens,omitempty"@json:"input_tokens"@' internal/span/response.go
