#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure.boilerplate bleibt unbesetzt (keine deklarierte Floskel)
#
# Setzt `boilerplate: ["Platzhalter"]` unter `closure:` — eine deklarierte Floskel-Liste wirkt
# rueckwirkend auf ALLE Kandidaten (Slice-Plan slice-129 §6: "Die Floskel-Liste ist die Stelle, an
# der dieser Slice sich selbst rot faerben kann"). `docs-check` selbst faerbt darauf jede Notiz rot,
# die eine der genannten Phrasen traegt, ohne dass eine Substanz-Aussage dahintersteht; dieser
# Waechter haelt die Nicht-Besetzung ohne einen Docker-Lauf.
set -euo pipefail
sed -i 's#^    dir: docs/plan/planning/done$#    dir: docs/plan/planning/done\n    boilerplate: ["Platzhalter"]#' .d-check.yml
