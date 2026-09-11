#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestRollenAchseFolgtDerEinenQuelle
#
# KUERZT NUR DIE ABBILDUNG, NICHT DIE QUELLE: CanonicalRoles fuehrt weiterhin sechs
# Namen (der emittierte Typ-Bestand bleibt vollstaendig), aber RoleFromAgentType
# normalisiert "planner" nicht mehr auf sich selbst — ein Typ mit genau diesem Namen
# liefe, triege aber ein leeres Rollen-Feld.
#
# WARUM DIESER FALL NEBEN 303 NOETIG IST: 303 kuerzt Quelle UND Abbildung zusammen (sie
# lesen dieselbe Liste) und deckt darum nur die Laengen-Pruefe. Dieser Fall isoliert die
# ZWEITE Haelfte — "fuer jeden Namen der Quelle ein nicht-leeres Rollen-Feld" — von der
# Laenge: die Quelle bleibt bei sechs, nur eine einzelne Normalisierung faellt aus.
set -euo pipefail
sed -i 's@if agentType == role {@if agentType == role \&\& role != "planner" {@' internal/span/emit.go
