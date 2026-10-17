#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: TestJavaCodeGateFragment_EigeneTagVariable
#
# Das Java-Fragment setzt seinen Tag unter dem Namen GRADLE_TAG, den das Kotlin-Fragment mit
# `?=` ebenfalls setzt -> der erste gelesene Wert gaelte fuer beide Sprachen, SKEL_JAVA_VERSION
# waere kein eigener Knopf (ADR-0094 Festlegung 2).
set -euo pipefail
sed -i 's/^JAVA_GRADLE_TAG ?=/GRADLE_TAG ?=/' internal/gen/java.go
