#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestAgentGetsNoArgumentFields
#
# NIMMT `omitempty` VON `spawned_role` — DIESELBE MUTATION WIE FALL 137, ANDERE BINDUNG.
# Die Draht-Form (abwesend statt `""`) ist an der geschriebenen Zeile in ZWEI Waechtern
# zugesagt, und JEDER traegt dafuer seinen EIGENEN `mustNotContain`-Eintrag:
# `TestAgentGetsNoArgumentFields` (erfolgreicher `Agent`-Aufruf ohne `tool_response`) und
# `TestFailedAgentCallCapturesNothing` (Fehlschlag ohne `tool_response`). Der Treiber
# sucht je Fall GENAU EINEN Namen in der Fehlschlag-Ausgabe (Bedingung 4) — ein Fall kann
# also hoechstens einen der beiden Eintraege binden. 137 nennt den Fehlschlag-Waechter,
# dieser Fall den erfolgreichen; erst zusammen sind beide Eintraege gebunden.
#
# WARUM DER EINTRAG IM ERSTEN WAECHTER TRAGEND IST, obwohl derselbe Test zwei Zeilen
# tiefer `s.SpawnedRole != ""` prueft: die Strukt-Pruefung kann die Draht-Form
# STRUKTURELL nicht sehen. Das Feld ist in BEIDEN Draht-Formen `""` — ueber Anwesenheit
# oder Abwesenheit in der Zeile entscheidet allein das JSON-Tag. Der
# `mustNotContain`-Eintrag ist damit die einzige Zusicherung dieses Waechters, die den
# Unterschied ueberhaupt misst.
#
# ROT WERDEN ZWEI — ausgezaehlt ueber ALLE `--- FAIL:`-Zeilen des Laufs, nicht am
# erwarteten Namen abgelesen (2026-07-31, isolierte Kopie): beide Waechter oben, je mit
# der Meldung `"spawned_role" steht in der Span-Zeile`. Die uebrigen Waechter dieser
# Flaeche bekommen ihre Rolle aus dem Ergebnis und pruefen sie mit MESSWERT
# (`"spawned_role":"reviewer"` bzw. `"verifier"`) — ein fehlendes `omitempty` beruehrt
# sie nicht.
#
# ZWEISEITIG GEMESSEN (2026-07-31, beide Richtungen in je einem Lauf): streicht man
# `"spawned_role"` aus der `mustNotContain`-Liste des ERSTEN Waechters, meldet dieser
# Fall BEFUND ("rot, aber ... faellt nicht — falscher Grund") — der Lauf bleibt ueber den
# Fehlschlag-Waechter rot, aber der erwartete Name steht nicht mehr in der
# Fehlschlag-Ausgabe —, waehrend 137 weiter "ok" meldet und 132 ebenfalls "ok" (132
# faellt dann auf die Strukt-Pruefung durch). Streicht man den Eintrag stattdessen aus
# dem FEHLSCHLAG-Waechter, kehrt sich das um: 137 meldet BEFUND, dieser Fall "ok".
#
# DER ANKER TRIFFT NUR DIESES FELD: `json:"spawned_role,omitempty"` steht repo-weit genau
# einmal (internal/span/response.go, `SpawnedRole`).
set -euo pipefail
sed -i 's@json:"spawned_role,omitempty"@json:"spawned_role"@' internal/span/response.go
