#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestErfassungFragment_LiegtAuchOhneTraeger
# verify: test-go
#
# HAENGT DAS AUFRAEUM- UND BERICHTS-FRAGMENT AN DEN ZWEIG DES TRAEGERS: scheitert dessen
# Ablage, bekommt das Ziel es nicht mehr.
#
# Die naheliegende Verwechslung, und sie hat einen richtigen Kern: Wrapper, Hook-Eintrag
# und Feldliste teilen diesen Zweig wirklich (ADR-0022 Festlegung 5(a) und 7), weil jedes
# von ihnen eine Aussage UEBER eine Erfassung ist, die dann nicht im Ziel liegt. Das
# Fragment ist keine Aussage, sondern ein KOMMANDO: `span-clean` braucht den Traeger gar
# nicht — ein Bestand aus einem frueheren Lauf ueberlebt ihn —, und `span-report` prueft
# ihn, statt ihn vorauszusetzen. Nach dieser Mutation steht ein Adopter, dessen Ablage
# einmal scheiterte, ohne Aufraeum-Kommando vor einem Bestand, der unbegrenzt waechst.
set -euo pipefail
sed -i 's@^\t\tcontent, err := enforceContent(f.src, captured)$@\t\tif f.dst == ErfassungMkPath \&\& !captured {\n\t\t\tcontinue\n\t\t}\n&@' internal/emit/enforce.go
