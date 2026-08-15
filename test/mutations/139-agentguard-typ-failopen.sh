#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-agent-guard.sh
# expect: guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)
#
# Laesst einen Agenten-Aufruf ohne lesbaren Subagent-Typ wieder durch — fail-open
# statt fail-closed, und damit die letzte Unterscheidung, die dieser Guard trifft.
#
# Der Hook haengt an "matcher": "Agent"; jeder Aufruf, den er sieht, ist ein
# Agenten-Aufruf. Mit dieser Mutation gilt eine Payload, aus der der Extraktor
# keinen Typ holt, als gelesen — der Guard antwortet dann auf eine Aufrufform, die
# er nicht kennt, mit Durchlassen statt mit Verweigern, ohne dass irgendetwas rot
# wird. Die Gegenrichtung faehrt Fall 150: dort verweigert er, was er kennt.
#
# Rot wird in test/agent-guard.bats „Agent-Aufruf ohne Subagent-Typ -> DENY". Die
# uebrigen guard-Faelle bleiben gruen: sie tragen alle einen Typ, und keiner von
# ihnen unterscheidet fail-open von fail-closed an DIESER Stelle.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, s. test/mutations/117); das `&`
# der Ersetzung ist escaped, sonst setzte sed dort den ganzen Treffer ein.
set -euo pipefail
sed -i "s@^\[ \"\$stype\" = \"ABSENT\" \] && .*\$@[ \"\$stype\" = \"ABSENT\" ] \&\& exit 0@" .claude/hooks/pretooluse-agent-guard.sh
