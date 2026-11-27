#!/usr/bin/env bash
# files: harness/tools/traeger-fetch-host.sh
# expect: happy im Pin-Modus: mit exportiertem Pin verifiziert
# verify: test-bats
#
# Entzaubert die Byte-Verifizierung am docker-losen Träger-Fetch am Host
# (Pflicht-Weg je ADR-0109, Pin-Kopplung je ADR-0059): `[ "$ist" != "$sha" ]`
# wird zu `[ -n "$ist" ]` — die Pruefung feuert dann an JEDEM geladenen Asset
# und misst nichts. ROT, vollstaendige Menge (Hand-Mutation an der realen
# Datei, gemessen): Test 1 (happy im Pin-Modus — der Lauf bricht mit der
# Abweichungs-Meldung trotz gleicher Summen), Test 2 (happy im Manifest-Modus,
# dieselbe Bedingung) und Test 7 (plattform-matrix — zwei happy-Laeufe auf
# derselben Bedingung). GRUEN bleiben die Negative-Tests 3 und 4: ihr
# erwarteter Fehlschlag-Typ (Exit != 0 + Meldung) trifft unter der Mutation
# zufaellig denselben Wortlaut — die Meldung allein misst den Zahn nicht; die
# Happy-Faelle tragen die Bedingung.
set -euo pipefail
sed -i "s/\[ \"\$ist\" != \"\$sha\" \]/[ -n \"\$ist\" ]/" harness/tools/traeger-fetch-host.sh
