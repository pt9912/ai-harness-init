#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: laesst das docs-check des Ziels GRUEN
# verify: full-smoke
#
# DIE EMITTIERTE .d-check.yml NIMMT DIE FELDLISTE AUS DEM DOKU-GATE DES ZIELS: ihr Pfad
# bleibt harness/erfassung-feldliste.md, aber scan.ignore fuehrt ihn danach.
#
# Das Dokument liegt danach im Ziel, und ein blosses „ist da" saehe es nicht: die Zusage
# aus ADR-0022 Festlegung 7 ist nicht die Anwesenheit, sondern der GEPRUEFTE Bereich —
# dorthin gehoert eine Aussage an den Adopter, weil sein Doku-Gate sie dort liest.
#
# WARUM DER PFAD STEHEN BLEIBT: die Stufe Handbuch-Baum in harness/tools/full-smoke.sh
# steht vor der Feldlisten-Stufe und haelt die im Handbuch genannten Pfade gegen den Bestand
# des frischen Ziels; der Pfad harness/erfassung-feldliste.md ist dort genannt, der Fall 615
# haelt diese Stufe fuer die Ablage dieser Datei. Bei unverrueckter Ablage bleibt
# die Stufe gruen, und die Ausnahme sieht allein der Zahn im Ziel — ein toter Verweis in
# der Feldliste, den docs-check des Ziels melden muss.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: welcher Baum geprueft wird,
# entscheidet die emittierte .d-check.yml IM ZIEL, und das zeigt nur ein Lauf, der
# bootstrappt und dort das Doku-Gate faehrt. Der Preis dieses Modus steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i 's@^  ignore: \["\*\*/\*\.template\.md", "\.tmp/\*\*", "\.harness/\*\*"\]$@  ignore: ["**/*.template.md", ".tmp/**", ".harness/**", "harness/erfassung-feldliste.md"]@' internal/emit/templates/d-check.yml
