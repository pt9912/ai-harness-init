#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramNeverEmitsAssignmentValueFragments
#
# WERT-GRENZE: `valueEdgeKnown` haelt jeden Zuweisungs-Wert fuer ein einzelnes Feld. Ein
# Wert mit Leerraum (`TOKEN="abc SECRET" gh pr create`) zerfaellt danach an der
# Zerlegung, und das Bruchstueck `SECRET"` steht als `program` in der Span-Zeile.
#
# DER PFAD IST STILL: entfaellt die Pruefung, bricht nichts ab und keine Fehlermeldung
# entsteht — das Programm wird nur falsch, und das Bruchstueck ist ein Stueck des Werts,
# den ADR-0011 nie ins Log laesst. Rot wird darum der Waechter, der die GESCHRIEBENE
# Zeile auf das Bruchstueck liest, nicht ein Absturz.
set -euo pipefail
sed -i 's|^\treturn !strings.ContainsAny(value, unsureValueChars)$|\t_ = value\n\treturn true|' internal/span/span.go
