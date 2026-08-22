#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestNoResponseFreetextReachesSpan
#
# ENTFERNT EINEN EINTRAG DER POSITIV-LISTE: `cache_creation_input_tokens` faellt aus
# responseKeys(), die uebrigen acht bleiben stehen. Der Emitter erfasst danach acht von
# neun Werten, und zwar STILL — die Span-Zeile sieht aus wie ein erfasster Lauf, nur
# ohne dieses Feld.
#
# WARUM ES DIESEN FALL BRAUCHT: ADR-0021 Festlegung 2 sagt zu, dass die Erfassung
# unveraendert BEREIT bleibt, obwohl heute keine Payload Zaehler liefert — "permanent
# ist die Abwesenheit der QUELLE, nicht die Abwesenheit des Schemas". Die realistische
# Fehlhandlung dagegen ist das Aufraeumen: wer einen Eintrag streicht, weil nie einer
# ankommt, macht aus einer fehlenden Quelle ein fehlendes Feld — und dann ist der
# Unterschied zwischen "unbekannt" und "nicht vorhanden" auch dann noch weg, wenn die
# Zaehler zurueckkommen. Diese RICHTUNG hatte bis hier keinen Zahn: 123..126 FUEGEN
# einen Freitext-Schluessel HINZU, 127 negiert die GRENZE der Liste, und
# `grep -ln 'responseKeys' test/mutations/*.sh` war leer (Exit 1). Ohne diesen Fall
# bleibt `make mutate` gruen, waehrend Festlegung 2 eine Absicht ist.
#
# WARUM EIN CACHE-ZAEHLER UND NICHT IRGENDEIN EINTRAG: `TestOnlyAgentToolGetsResponseValues`
# haelt die WERKZEUG-Achse und prueft in seiner Gegenprobe vier der neun Werte
# (SpawnedRole, TotalTokens, InputTokens, ModelVersion). Die zwei Cache-Zaehler gehoeren
# nicht dazu; ein Eintrag aus dieser Ecke laesst ihn gruen, und der benannte Waechter
# faellt allein. Ein Griff nach `agentType` oder `totalTokens` roetete beide und machte
# "151 rot" mehrdeutig.
#
# ROT WIRD GENAU EINER: `TestNoResponseFreetextReachesSpan` fordert die neun gelisteten
# Werte namentlich (`mustContain`), und `"cache_creation_input_tokens":33` fehlt dann in
# der Zeile. `TestUnlistedResponseKeyStaysOut` prueft `spawned_role`, `input_tokens` und
# `total_tokens`, `TestFailedAgentCallCapturesNothing` die ABWESENHEIT aller neun —
# beide bleiben gruen.
set -euo pipefail
sed -i '/{path: \[\]string{"usage", "cache_creation_input_tokens"}/d' internal/span/response.go
