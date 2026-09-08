#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: head-allow ist voll verankert und traegt Accepted/Deprecated/Link-Supersede
#
# Setzt `head-allow` auf die Vor-Fix-Form zurueck: ohne Endanker ($), ohne den vollen
# Link-Ziel-Teil und ohne `Deprecated`. Ohne den Endanker faengt das Muster nur ein Praefix ab —
# ein beliebiger Zusatz hinter `Accepted` (etwa "Accepted (ueberholt, siehe ADR-NNNN)") passt
# dann durch, obwohl genau diese Zeile die Statuszeile einer angenommenen ADR ist, um die
# AGENTS.md 3.4 geht (Review-Gegenbeispiel, gemessen: 0 Befund(e) mit dieser Form, 1 Befund(e)
# mit dem End-Anker).
set -euo pipefail
sed -i "s/^  head-allow: '.*'\$/  head-allow: '^\\\\*\\\\*Status:\\\\*\\\\* (Accepted|Superseded by \\\\[ADR-[0-9]{4}\\\\])'/" .d-check.yml
