#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramNeverEmitsAssignmentValueFragments
#
# WORT-GRENZE: `splitWords` haelt nur noch ASCII-Nicht-Leerraum-Bytes fuer Wortbestandteil;
# jedes Byte >= 0x80 -- jede Fortsetzungs- oder Startbyte einer Mehrbyte-UTF-8-Folge (NBSP,
# U+2003, U+3000, U+0085) -- wird danach faelschlich zur Wortgrenze. Ein Wert wie
# `A=b<NBSP>SECRET` zerfaellt danach, und das Bruchstueck `SECRET` steht als `program` in
# der Span-Zeile, obwohl die Shell es als Teil des Werts fuehrt (ADR-0011: Werte nie im
# Span). `\r`/`\v`/`\f` bleiben von dieser Mutation unberuehrt (alle < 0x80) -- die vier
# Unicode-Faelle genuegen, die Testfunktion insgesamt rot zu faerben.
#
# DER PFAD IST STILL: kein Absturz, nur ein falsches Wort. Rot wird der Waechter, der die
# GESCHRIEBENE Zeile auf `SECRET` liest — Fall `A=b<NBSP>SECRET cmd` und seine Verwandten
# (U+2003, U+3000, U+0085).
set -euo pipefail
sed -i "s@^\t\tif c != ' ' && c != '\\\\t' && c != '\\\\n' {\$@\t\tif c != ' ' \\&\\& c != '\\\\t' \\&\\& c != '\\\\n' \\&\\& c < 0x80 {@" internal/span/span.go
