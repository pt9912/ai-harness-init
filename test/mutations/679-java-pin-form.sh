#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: TestGenerate_JavaVersionThreaded
#
# DefaultJavaVersion verliert den JDK-Teil -> kein gradle-Tag der Form <ver>-jdk<NN> mehr;
# das Image-Tag bestimmte kein JDK und waere ein anderer Pin (ADR-0094 Festlegung 2).
set -euo pipefail
sed -i 's/^const DefaultJavaVersion = "9.8.1-jdk21"$/const DefaultJavaVersion = "9.8.1"/' internal/gen/java.go
