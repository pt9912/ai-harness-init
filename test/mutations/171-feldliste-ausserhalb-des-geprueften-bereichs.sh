#!/usr/bin/env bash
# files: internal/emit/fieldlist.go
# expect: die Feldliste liegt nicht im GEPRUEFTEN Doku-Bereich
# verify: full-smoke
#
# DIE FELDLISTE ZIEHT UNTER .harness/ — den Baum, den die emittierte .d-check.yml aus dem
# Doku-Gate des Ziels ausnimmt.
#
# Das Dokument laege danach im Ziel, und ein blosses „ist da" saehe es nicht: die Zusage
# aus ADR-0022 Festlegung 7 ist nicht die Anwesenheit, sondern der GEPRUEFTE Bereich —
# dorthin gehoert eine Aussage an den Adopter, weil sein Doku-Gate sie dort liest.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: welcher Baum geprueft wird,
# entscheidet die emittierte .d-check.yml IM ZIEL, und das zeigt nur ein Lauf, der
# bootstrappt und dort das Doku-Gate faehrt. Der Preis dieses Modus steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i 's@^const FieldListPath = "harness/erfassung-feldliste.md"$@const FieldListPath = ".harness/erfassung-feldliste.md"@' internal/emit/fieldlist.go
