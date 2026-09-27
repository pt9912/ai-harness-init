#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_BestandOhneAgentLaufMeldetEigeneLage
# verify: test-go
#
# LEGT DIE LAGE "KEIN AGENTEN-LAUF" MIT DER LAGE "AGENT OHNE ZAEHLER" ZUSAMMEN: ein
# Bestand aus lauter Nicht-Agenten-Zeilen faellt dann auf leereDerZaehler() durch und
# traegt den Mechanik-Grund-Satz, obwohl kein Agenten-Aufruf lief, dessen Zaehler
# fehlen koennten.
#
# Die Mechanik des Agenten-Werkzeugs traegt hier keine Schuld an einer Leere, die sie
# nicht verursacht hat — der Grund-Satz waere in genau diesem Fall die falsche
# Begruendung (slice-071 DoD (2)).
set -euo pipefail
sed -i 's@	case b.AgentLaeufe == 0:@	case false:@' internal/report/report.go
