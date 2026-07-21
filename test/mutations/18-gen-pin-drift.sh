#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGoProfile_PinsMatchRepo
#
# Der gepinnte Go-Default des Generators driftet vom Repo-Dockerfile weg — genau
# die Klasse, die der Kopplungstest fangen soll (eine Haelfte gebumpt, die andere
# vergessen; slice-004a-Lehre, LH-QA-02).
set -euo pipefail
sed -i 's/DefaultGoVersion = "1.26.4"/DefaultGoVersion = "9.9.9"/' internal/gen/golang.go
