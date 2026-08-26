#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestFeldliste_KeineFeldlisteOhneTraeger
# verify: test-go
#
# DIE FELDLISTE WIRD UNBEDINGT GESCHRIEBEN, statt den Zweig des Traegers zu teilen.
#
# Die naheliegende Bequemlichkeit — „ein Dokument schadet doch nicht" — und genau die
# Stelle, an der ADR-0022 Festlegung 5(a) etwas anderes sagt: scheitert die Ablage des
# Traegers, wird BEGRUENDET NICHTS abgelegt. Ein Ziel ohne Erfassung mit einer Feldliste
# beschreibt eine Erfassung, die dort nicht liegt.
#
# ISOLIERT auf diese eine Zusage: der Hook-Wrapper und der Erfassungs-Block bleiben
# unberuehrt, TestEnforce_KeineErfassungOhneTraeger bleibt also gruen. Ein Fall, der die
# Bedingung selbst umlegte, faerbte beide — und „rot" hiesse dann nicht mehr eindeutig
# „die Feldliste teilt den Zweig nicht".
set -euo pipefail
sed -i 's@^\tcaptureErr := placeCarrier(targetDir)$@&\n\tif feldErr := FieldList(targetDir); feldErr != nil {\n\t\treturn feldErr\n\t}@' internal/emit/enforce.go
