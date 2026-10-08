#!/usr/bin/env bash
# files: internal/archive/stub.go
# expect: TestTitelVonStreiftDenNamen
# verify: test-go
#
# Verengt kennungRE auf eine Ziffer am Kennungs-Anfang: die benannte Kennung
# bleibt dann im Titel des Stubs stehen.
set -euo pipefail
sed -i 's/-\[0-9A-Za-z\]\[A-Za-z0-9-\]\*\\s\*/-[0-9]+[A-Za-z0-9-]*\\s*/' internal/archive/stub.go
