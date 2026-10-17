#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_JavaTraegtDieHostToolchain
#
# mvn und mvnw verschwinden aus dem blocked/java-Fragment -> der naheliegende Host-Umweg an
# der verworfenen Maven-Alternative laeuft im Ziel ungehindert (ADR-0094 Festlegung 5). Das
# Fragment bleibt nicht-leer; der Kopplungs-Test ueber alle gen-Profile bleibt gruen.
set -euo pipefail
sed -i 's/ mvn mvnw\\n",$/\\n",/' internal/emit/enforce.go
