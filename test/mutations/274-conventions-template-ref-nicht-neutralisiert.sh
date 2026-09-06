#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_ConventionsTemplateRefGateSafe
#
# Der NeutralizeConventionsTemplateRef-Aufruf faellt weg -> die emittierte
# harness/conventions.md traegt wieder den baseline-relativen Inline-Code-Pfad
# harness/conventions/MR-NNN-titel.template.md, den es im Ziel-Repo unter
# diesem Namen nicht gibt (ADR-0037 Festlegung 1, Fundstelle 1). Der if-Rumpf
# bleibt leer, aber conventionsTemplate wird weiter in der Bedingung genutzt ->
# kompiliert.
set -euo pipefail
sed -i '/body = NeutralizeConventionsTemplateRef(body)/d' internal/emit/templates.go
