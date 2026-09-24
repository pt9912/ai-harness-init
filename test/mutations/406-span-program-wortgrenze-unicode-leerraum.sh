#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramNeverEmitsAssignmentValueFragments
#
# WORT-GRENZE: die Zerlegung trennt an jedem Unicode-Leerraum (`strings.Fields`) statt nur an
# Leerzeichen, Tab und Zeilenende. Ein Wert wie `A=b<NBSP>SECRET` zerfaellt danach, und das
# Bruchstueck `SECRET` steht als `program` in der Span-Zeile, obwohl die Shell es als Teil
# des Werts fuehrt (ADR-0011: Werte nie im Span).
#
# DER PFAD IST STILL: kein Absturz, nur ein falsches Wort. Rot wird der Waechter, der die
# GESCHRIEBENE Zeile auf `SECRET` liest — Fall `A=b<NBSP>SECRET cmd` und seine Verwandten
# (U+2003, U+3000, U+0085, `\r`, `\v`, `\f`).
set -euo pipefail
sed -i 's@^\tfields := splitWords(cmd)$@\tfields := strings.Fields(cmd)@' internal/span/span.go
