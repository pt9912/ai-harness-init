#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-agent-guard.sh
# expect: guard: JEDER Typ in .claude/agents/ laeuft durch
#
# Baut dem Guard wieder einen Zweig ein, der einen Rollen-Typ verweigert — die
# Bedingung, an der am 2026-08-15 alle sechs Rollen scheiterten.
#
# Der Zweig ist nicht theoretisch: er stand hier, solange das Eingabe-Schema von
# `Agent` ein `run_in_background` fuehrte, und er wurde unerfuellbar, als das Feld
# daraus verschwand (gemessen in
# docs/reviews/2026-08-15-agent-guard-tool-vertrag.md). Kaeme er zurueck — als
# Betriebsart-Forderung, als Namensliste oder als Existenzpruefung wie hier —,
# waere jeder Rollen-Lauf wieder blockiert, ohne dass ein Gate es meldet: die
# lautlose Variante des Schadens, diesmal in der Gegenrichtung zu Fall 139.
#
# Rot wird in test/agent-guard.bats „JEDER Typ in .claude/agents/ laeuft durch".
# Die uebrigen guard-Faelle bleiben gruen: ihre Typen haben keine Datei im
# Verzeichnis, und die DENY-Faelle erreichen diese Zeile gar nicht.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, s. test/mutations/139): der
# Zielausdruck traegt zwei Shell-Variablen. Das `&` der Ersetzung ist escaped,
# sonst setzte sed dort den ganzen Treffer ein.
set -euo pipefail
sed -i "s@^exit 0\$@[ -f \"\$here/../agents/\$stype.md\" ] \&\& { emit_deny \"MUTIERT: Rollen-Typ abgewiesen\"; exit 0; }; exit 0@" .claude/hooks/pretooluse-agent-guard.sh
