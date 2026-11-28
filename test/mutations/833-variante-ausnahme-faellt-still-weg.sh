#!/usr/bin/env bash
# files: .gitignore harness/tools/working-tree-hash.sh
# expect: gitignore: die committete Key-Klasse und der E2E-Stempel sind nicht ignoriert
# verify: test-bats
#
# DIE AUSNAHME DER STAMPPEL-KLASSE FAEHLT STILL WEG (ADR-0113 Festlegung 5/6,
# a-2): die gitignore-Negation `!.harness/state/full-smoke-passed-*.key` und der
# zugehoerige HASH_AUSNAHMEN-Eintrag entfallen — die Klasse faellt wieder in den
# Ignorier-Bereich bzw. in den Baum-Hash, der Klon transportiert die sieben
# Stempel nicht mehr, und ein Stempel-Commit rotiert mit.
#
# Waechter ist der check-ignore-Fall in test/ci-stempel-committed.bats
# ("gitignore: die committete Key-Klasse und der E2E-Stempel sind nicht
# ignoriert"): er misst die reale .gitignore und faellt, sobald die Klasse
# wieder in den Ignorier-Bereich faellt; dieselbe Loeschung faellt den
# Stempel-Ausnahme-Fall in test/working-tree-hash-abnahme.bats
# ("stempel-ausnahme: ein committeter je-Check-Key und der E2E-Stempel unter
# .harness/state/ bewegen den Hash nicht") am Baum-Hash-Waechter.
set -euo pipefail
sed -i '/^!\.harness\/state\/full-smoke-passed-\*\.key$/d' .gitignore
sed -i "/\.harness\/state\/full-smoke-passed-\*\.key'/d" harness/tools/working-tree-hash.sh
