#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: Handbuch-Baum (dokument-only): im Handbuch genannt, vom Lauf nicht angelegt: [harness/erfassung-feldliste.md]
# verify: full-smoke
#
# Die Erfassungs-Stufe (emit.Enforce) schreibt die Feldliste nicht mehr, obwohl der
# Traeger abgelegt ist. Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh steht
# vor jeder anderen Ziel-Stufe und muss den Pfad als genannt, aber nicht angelegt melden —
# der Zahn haelt, dass ihre Soll-Menge die ganze Init-Strecke ist und nicht die
# Vorlagen-Stufe allein.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^\treturn FieldList(targetDir)$/\treturn nil/' internal/emit/enforce.go
