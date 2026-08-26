#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestSchemaDoc_KeinEintragOhneErfasstesFeld
# verify: test-go
#
# DER AUSDRUCK BEHAUPTET EINE ERFASSUNG, DIE ES NICHT GIBT: ein Eintrag fuer `prompt`,
# das der Traeger nie schreibt.
#
# Die ANDERE Bruchstelle derselben Zusage — und die gefaehrlichere Richtung, weil sie
# beruhigt: eine Feldliste, die mehr nennt als erfasst wird, laesst einen Leser nach
# Zeilen suchen, die nie entstehen. `prompt` ist mit Absicht gewaehlt: es ist das Feld,
# das nach ADR-0011 Festlegung 2 nie ins Log darf, und eine Liste, die es fuehrt, sagt
# das Gegenteil.
set -euo pipefail
sed -i 's@{Field: "seq", Question:@{Field: "prompt", Question: "Was stand im Auftrag?"},\n\t\t{Field: "seq", Question:@' internal/span/fieldlist.go
