#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestSpansLandInStateDir
#
# Zieht den Ablageort auf einen GETRACKTEN Pfad.
#
# Das ist Zeile 3 der Fitness Function von ADR-0011 woertlich — sie hatte bis hierher
# keinen Mutations-Fall (Review-Befund HIGH-4). Die Eigenschaft war gemessen
# (TestSpansLandInStateDir, `make span-check` mit `git check-ignore` am realen Repo),
# ihre HALTBARKEIT aber unbewacht: beide Sensoren haetten still gruen werden koennen.
#
# Das Fehlerbild ist der Selbstblockierer aus MR-003: ein Span im getrackten Baum
# verschiebt den working-tree-hash bei JEDEM Tool-Call, und der Stop-Hook laesst
# keinen Abschluss mehr zu.
set -euo pipefail
sed -i 's@^const Dir = ".harness/state/spans"$@const Dir = "docs/spans"@' internal/span/emit.go
