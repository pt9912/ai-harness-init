#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestSpawnedRoleIsNormalised
#
# DIE NORMALISIERUNG WIRD ENTFERNT: `spawned_role` uebernimmt den Rohwert aus
# `tool_response.agentType`, statt ihn gegen die sechs kanonischen Rollennamen zu halten.
# Danach steht `general-purpose` als Rolle im Span — genau die erfundene Kostenstelle,
# die die Lesevorschrift in spec/spezifikation.md §5 verbietet („eine Ergebniszeile
# `general-purpose: 62 %`"). `Reviewer`, `reviewer-2` und `reviewer ` kaemen ebenso durch.
#
# WARUM ES DIESEN FALL BRAUCHT: MR-018 §Bewacht sagte bis zum 2026-07-30, die
# Normalisierung sei „einmal rot gesehen worden" und berief sich dafuer auf einen
# Implementations-Bericht, den es im Repo nie gab (Review-Befund MEDIUM-3). Zugleich
# stand dort, dass ein DAUER-Sensor fehlt — der Waechter konnte seine Zaehne verlieren,
# ohne dass `make mutate` es meldet. Dieser Fall loest beides: der Beleg ist der Lauf,
# und er wiederholt sich bei jedem `make mutate`.
#
# GEMESSEN WIRD DIE WIEDERVERWENDUNG, nicht eine zweite Abbildung: `roleFromAgentType`
# lebt in internal/span/emit.go und fuellt dort `agent_role`. Wer daneben eine eigene
# Abbildung fuer `spawned_role` baut, faellt hier ebenso — der Rohwert ist nur der
# einfachste Weg dorthin.
#
# ROT WIRD GENAU EINER: die uebrigen Waechter dieser Flaeche fahren `reviewer` oder
# `verifier` durch, also Werte, die die Normalisierung unveraendert laesst. Damit ist
# „128 rot" gleichbedeutend mit „die Normalisierung greift" (Bedingung 4 des Treibers).
set -euo pipefail
sed -i 's@roleFromAgentType(text(v))@text(v)@' internal/span/response.go
