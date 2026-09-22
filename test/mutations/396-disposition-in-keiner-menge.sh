#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt
#
# gate.template.md faellt aus isRecurring heraus, landet aber in KEINER der
# drei anderen Dispositionen (isDerivativeIndex, isBrownfieldOnly, der
# benannten Singleton-Liste des Waechters) — die Bezugsmenge deckt die
# Vorlage danach in keiner der vier Mengen mehr (ADR-0057 Festlegung 1,
# Rot-Bedingung 1: Vollstaendigkeit). Im Dispatch selbst faellt sie
# stillschweigend auf den Singleton-Default zurueck und wird emittiert, ohne
# dass irgendetwas rot wuerde — genau die Stelle, die der Waechter bewacht.
# Kompiliert weiter.
set -euo pipefail
sed -i 's/"observation.template.md", "gate.template.md":/"observation.template.md":/' internal/emit/templates.go
