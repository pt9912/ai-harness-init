#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: TestJavaLintConfig_TraegtUnusedImportsUndMaxWarnings
#
# maxWarnings = 0 verschwindet aus build.gradle.kts -> eine Checkstyle-Warnung wuerde das
# Lint-Gate nicht mehr faerben (ADR-0094 Festlegung 3).
set -euo pipefail
sed -i '/^    maxWarnings = 0$/d' internal/gen/java.go
