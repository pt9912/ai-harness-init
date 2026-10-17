#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: TestJavaLintConfig_TraegtUnusedImportsUndMaxWarnings
#
# UnusedImports verschwindet aus der Checkstyle-Config des Skeletts -> der Lint-Fall der
# Fitness Function (unbenutzter Import) bliebe ungeprueft, statt zu brechen (ADR-0094
# Festlegung 3). Die Einzelmessung im gebootstrappten Ziel faehrt Fall 683.
set -euo pipefail
sed -i '/<module name="UnusedImports"\/>/d' internal/gen/java.go
