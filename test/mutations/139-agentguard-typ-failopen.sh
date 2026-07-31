#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-agent-guard.sh
# expect: guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)
#
# Laesst einen Agenten-Aufruf ohne lesbaren Subagent-Typ wieder durch — fail-open
# statt fail-closed, und damit die entgegengesetzte Antwort zu der, die derselbe
# Guard zwoelf Zeilen tiefer auf den fehlenden Schalter gibt.
#
# Der Hook haengt an "matcher": "Agent"; jeder Aufruf, den er sieht, ist ein
# Agenten-Aufruf. Mit dieser Mutation entscheidet er bei unlesbarem Typ auf "kein
# Rollen-Aufruf" und laesst ihn laufen — ein Rollen-Lauf, dessen Typ den Extraktor
# nicht erreicht, startet dann in der Betriebsart des Aufrufers. Im Hintergrund
# traegt seine Antwort weder Nutzungszaehler noch agentType; die Rollen-Achse der
# Telemetrie bliebe leer, ohne dass irgendetwas rot wird (slice-060, MR-018) — die
# lautlose Variante des Schadens, dieselbe wie bei Fall 119.
#
# Rot wird in test/agent-guard.bats „Agent-Aufruf ohne Subagent-Typ -> DENY". Die
# uebrigen guard-Faelle bleiben gruen: sie tragen alle einen Typ, und keiner von
# ihnen unterscheidet fail-open von fail-closed an DIESER Stelle.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, s. test/mutations/117); das `&`
# der Ersetzung ist escaped, sonst setzte sed dort den ganzen Treffer ein.
set -euo pipefail
sed -i "s@^\[ \"\$stype\" = \"ABSENT\" \] && .*\$@[ \"\$stype\" = \"ABSENT\" ] \&\& exit 0@" .claude/hooks/pretooluse-agent-guard.sh
