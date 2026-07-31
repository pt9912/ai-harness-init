#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestFailedAgentCallCapturesNothing
#
# NIMMT `omitempty` VON `spawned_role`. Danach steht `"spawned_role":""` in JEDER
# Zeile — auch in jedem `Bash`-Span, der nie einen Subagenten gestartet hat.
#
# DAS IST DIE DRAHT-FORM, AUF DER EINE LESEVORSCHRIFT RUHT, nicht eine Formalie.
# harness/conventions.md MR-018 legt fuer `spawned_role` ausdruecklich die ANDERE
# Draht-Form fest als fuer `agent_role`: `agent_role` ist Pflicht und steht als `""` in
# jeder Zeile, `spawned_role` ist `omitempty` und FEHLT bei leerem Wert. Ein
# `"spawned_role":""` in jedem `Bash`-Span behauptete einen Subagenten, den es nicht
# gab — und eine Auswertung, die den Sammelposten ueber die Abwesenheit des Feldes
# bildet, verlaesst sich genau darauf.
#
# WARUM ES DIESEN FALL BRAUCHT (Review-Befund MEDIUM-2 vom 2026-07-30): der Kommentar
# an `intoSpawnedRole` nannte fuer die Abwesenheit von `spawned_role` die Dauer-Sensoren
# 132 UND 134. Fall 134 mutiert `json:"input_tokens,omitempty"` und beruehrt
# `spawned_role` an keiner Stelle — gemessen bleibt er "ok", wenn man `"spawned_role"`
# aus der `mustNotContain`-Liste von `TestFailedAgentCallCapturesNothing` streicht (er
# faellt weiter ueber `input_tokens`, und Bedingung 4 des Treibers findet den erwarteten
# Namen). Fall 132 bindet die HERKUNFT und nur im ersten der beiden Waechter: der
# Fehlschlag-Waechter fuehrt `subagent_type: "nope"`, das zu leer normalisiert, und
# bleibt unter 132 absichtlich gruen. Die Draht-Form hatte damit ueberhaupt keinen Zahn.
# Dieselbe Fehlerform wie R2-MEDIUM-1 (Fall 110 und `tool`) und MEDIUM-4 (Fall 127 und
# `model_version`): der Kommentar schreibt einem existierenden Zahn einen Biss zu, den
# er nicht hat.
#
# ROT WERDEN ZWEI — ausgezaehlt ueber ALLE `--- FAIL:`-Zeilen des Laufs, nicht am
# erwarteten Namen abgelesen (2026-07-30, isolierte Kopie) —, und das ist hier richtig
# statt vermeidbar: die Abwesenheit von
# `spawned_role` ist an der geschriebenen Zeile in ZWEI Waechtern zugesagt —
# `TestAgentGetsNoArgumentFields` (erfolgreicher Aufruf ohne `tool_response`) und
# `TestFailedAgentCallCapturesNothing` (Fehlschlag ohne `tool_response`). Eine Mutation,
# die nur einen davon faerbt, gaebe es nur um den Preis, die Zusage kuenstlich zu
# verengen; dieselbe Lage wie bei Fall 131, dessen Kopf sie ebenso benennt. Die uebrigen
# Waechter dieser Flaeche bekommen ihre Rolle aus dem Ergebnis und pruefen sie mit
# MESSWERT (`"spawned_role":"reviewer"` bzw. `"verifier"`) — ein fehlendes `omitempty`
# beruehrt sie nicht.
#
# GEBUNDEN IST GENAU EIN EINTRAG — DER BENANNTE. `# expect:` nennt
# `TestFailedAgentCallCapturesNothing`, also bindet dieser Fall dessen
# `mustNotContain`-Eintrag: streicht jemand `"spawned_role"` dort, bleibt der Lauf zwar
# rot (ueber den anderen Waechter), aber Bedingung 4 des Treibers findet den erwarteten
# Namen nicht mehr in der Fehlschlag-Ausgabe und meldet BEFUND ("rot, aber ... faellt
# nicht — falscher Grund"). GEMESSEN am 2026-07-30, beide Seiten in EINEM Lauf: mit
# gestrichenem Eintrag meldet 134 weiter "ok" und DIESER Fall BEFUND. Genau das ist der
# Unterschied zu Fall 134.
#
# DEN EINTRAG DES ANDEREN WAECHTERS BINDET ER NICHT, und dafuer gibt es einen zweiten
# Fall: `test/mutations/138-span-rollenfeld-praesent-leer-erfolgsfall.sh` traegt dieselbe
# Mutation mit `# expect: TestAgentGetsNoArgumentFields`. Streicht man `"spawned_role"`
# aus DESSEN `mustNotContain`-Liste, meldet dieser Fall hier weiter "ok" (er faellt ueber
# den Fehlschlag-Waechter) und 138 BEFUND — gemessen am 2026-07-31. Die Strukt-Pruefung
# `s.SpawnedRole != ""` im ersten Waechter faengt es nicht: das Feld ist in beiden
# Draht-Formen `""`, ueber Anwesenheit entscheidet allein das JSON-Tag.
#
# DER ANKER TRIFFT NUR DIESES FELD: `json:"spawned_role,omitempty"` steht repo-weit
# genau einmal (internal/span/response.go, `SpawnedRole`).
set -euo pipefail
sed -i 's@json:"spawned_role,omitempty"@json:"spawned_role"@' internal/span/response.go
