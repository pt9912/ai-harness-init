#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-agent-guard.sh
# expect: guard: eine ERFUNDENE Rolle im Fixture-Verzeichnis wird abgelehnt (Ableitung, keine Kopie)
#
# Ersetzt die ABLEITUNG durch eine hart notierte Namensliste der heutigen sechs
# Rollen. Beide Fassungen verhalten sich fuer jeden Typ gleich, den das Repo heute
# fuehrt — der Unterschied ist die Zusage aus slice-060: „ein Typ ist genau dann eine
# Rolle, wenn `.claude/agents/<name>.md` existiert", damit keine vierte Kopie neben
# dem Verzeichnis, spec/spezifikation.md §5 und roleFromAgentType entsteht und der Guard nicht gegen
# das Verzeichnis veralten kann, das er bewacht.
#
# DIESER FALL IST DER EINZIGE DES SATZES, DER ABGELEITET VON KOPIERT UNTERSCHEIDET.
# In test/agent-guard.bats fallen die beiden Faelle mit Fixture-Verzeichnis
# (AGENT_GUARD_AGENTS_DIR): die frisch erfundene Rolle wird nicht mehr abgelehnt,
# und reviewer wird abgelehnt, obwohl das Fixture ihn nicht fuehrt. Jeder andere
# Test des Satzes bleibt gruen — eine Namensliste besteht sie alle.
#
# Anker in DOPPELTEN Anfuehrungszeichen (SC2016, s. test/mutations/117).
set -euo pipefail
sed -i "s@^\[ -f \"\$agents_dir/\$stype\.md\" \] || exit 0\$@case \"\$stype\" in planner|architect|implementer|reviewer|verifier|validator) ;; *) exit 0 ;; esac@" .claude/hooks/pretooluse-agent-guard.sh
