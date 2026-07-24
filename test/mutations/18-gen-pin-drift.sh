#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGoProfile_PinsMatchRepo
#
# Der gepinnte Go-Default des Generators driftet vom Repo-Dockerfile weg — genau
# die Klasse, die der Kopplungstest fangen soll (eine Haelfte gebumpt, die andere
# vergessen; slice-004a-Lehre, LH-QA-02).
#
# Match GENERISCH auf den Versions-Wert ([0-9.]*), NICHT auf einen festen String:
# sonst veraltet die Mutation bei jedem GO_VERSION-Bump (real passiert beim
# 1.26.4->1.26.5-Bump — die feste Fassung griff nicht mehr, BEFUND im mutate-Lauf).
set -euo pipefail
sed -i 's/DefaultGoVersion = "[0-9.]*"/DefaultGoVersion = "9.9.9"/' internal/gen/golang.go
