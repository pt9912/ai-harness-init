#!/usr/bin/env bash
# files: .d-check.yml
# expect: der konfigurierte waves.dir existiert als Verzeichnis
#
# Setzt `waves.dir` auf einen im Repo nicht existierenden Pfad (statt auf einen leeren Wert wie
# 319 oder ein existierendes Nachbarverzeichnis wie 321). Das `[ -d "$REPO/$d" ]`-Praedikat der
# Existenz-Zusicherung "der konfigurierte waves.dir existiert als Verzeichnis" wird von keinem der
# beiden anderen Faelle erreicht — 319 bricht vorher in der Leer-Vorpruefung ab, 321 zeigt auf ein
# Verzeichnis, das existiert (`docs/plan/planning/done`). Dieser Fall traegt einen nicht-leeren,
# nicht-existierenden Wert und faerbt damit genau dieses Praedikat rot (die Literal-Vergleichs-
# Zusicherung faellt als Nebenwirkung ebenfalls, das ist nicht das Ziel dieses Falls).
set -euo pipefail
sed -i 's/^\(    dir: \)docs\/plan\/planning$/\1docs\/plan\/planning\/nichtvorhanden-323/' .d-check.yml
