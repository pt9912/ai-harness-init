#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestRollenAchseFolgtDerEinenQuelle
#
# KUERZT DIE EINE QUELLE UM EINE ROLLE: CanonicalRoles fuehrt nur noch fuenf Namen.
# Damit schrumpft zugleich der emittierte Typ-Bestand (emit.canonicalRoles liest
# dieselbe Liste) UND die Abbildung des Traegers (RoleFromAgentType normalisiert gegen
# dieselbe Liste) — beide fallen zusammen, ohne dass ein zweiter Fundort noch
# widerspricht.
#
# WARUM DIESER WAECHTER UND NICHT NUR TestAgents_KanonischeRollenLiegenImZiel: jener
# haelt den emittierten Datei-Bestand gegen die (dann schon verkuerzte) Liste selbst und
# bliebe unter dieser Mutation intern konsistent. Dieser Fall bindet die feste Erwartung
# "sechs" in TestRollenAchseFolgtDerEinenQuelle, die unabhaengig von der Quelle gilt.
set -euo pipefail
sed -i 's@return \[\]string{"planner", "architect", "implementer", "reviewer", "verifier", "validator"}@return []string{"architect", "implementer", "reviewer", "verifier", "validator"}@' internal/span/emit.go
