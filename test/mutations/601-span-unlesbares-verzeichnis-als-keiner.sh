#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestCorrelationUnreadableDirIsMarkedNotKnown
#
# correlation liest ein vorhandenes, nicht lesbares Lifecycle-Verzeichnis als *kein Slice*:
# alle drei Listen stehen als `[]` statt mit der Kennzeichnung (SPEC-011, SPEC-087). Der
# Anker steht repo-weit genau einmal.
set -euo pipefail
sed -i 's@return IDList{Unknown: inProgress}, IDList{Unknown: inProgress}, IDList{Unknown: inProgress}@return IDList{IDs: []string{}}, IDList{IDs: []string{}}, IDList{IDs: []string{}}@' internal/span/emit.go
