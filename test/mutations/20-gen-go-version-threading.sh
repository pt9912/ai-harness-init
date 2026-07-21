#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_GoVersionThreaded
#
# Die uebergebene Go-Version faedelt nicht mehr ins Dockerfile: render ignoriert
# goVersion und setzt fix den Default ein — eine explizite Version haette keine
# Wirkung.
set -euo pipefail
sed -i 's/"{{GO_VERSION}}", goVersion/"{{GO_VERSION}}", DefaultGoVersion/' internal/gen/golang.go
