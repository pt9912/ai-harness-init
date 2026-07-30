#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-agent-guard.sh
# expect: guard: Rolle ohne Schalter -> DENY (Abwesenheit gilt als Hintergrund)
#
# Macht den FEHLENDEN Schalter zum Vordergrund — fail-open statt fail-closed.
#
# `run_in_background` fehlt im dokumentierten Eingabe-Schema von `Agent`, und in der
# Kontroll-Messung vom 2026-07-29 trugen die Vergleichs-Aufrufe das Feld gar nicht:
# ein weggelassener Schalter ist der NORMALFALL, nicht der Ausnahmefall, und der
# Standard ist Hintergrund. Mit dieser Mutation liefe ein Rollen-Agent ohne Schalter
# durch, seine Antwort truege weder Nutzungszaehler noch `agentType`, und die
# Rollen-Achse der Telemetrie bliebe leer, ohne dass irgendetwas rot wird
# (slice-060, MR-018) — die lautlose Variante des Schadens, gegen den der Guard steht.
#
# Rot wird in test/agent-guard.bats „Rolle ohne Schalter -> DENY". Die beiden
# ausdruecklichen Richtungen (true -> DENY, false -> PASS) bleiben gruen: sie
# unterscheiden fail-open von fail-closed nicht.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, s. test/mutations/117).
set -euo pipefail
sed -i "s@^\[ \"\$rib\" = \"false\" \] && exit 0\$@if [ \"\$rib\" = \"false\" ] || [ \"\$rib\" = \"ABSENT\" ]; then exit 0; fi@" .claude/hooks/pretooluse-agent-guard.sh
