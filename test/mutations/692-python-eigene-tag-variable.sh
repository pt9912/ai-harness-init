#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestPythonCodeGateFragment_EigeneTagVariable
#
# Das Python-Fragment setzt seinen Tag unter dem Namen JAVA_GRADLE_TAG, den das Java-Fragment
# mit `?=` ebenfalls setzt -> der erste gelesene Wert gaelte fuer beide Sprachen,
# SKEL_PYTHON_VERSION waere kein eigener Knopf (ADR-0095 Festlegung 2).
set -euo pipefail
sed -i 's/^PYTHON_TAG ?=/JAVA_GRADLE_TAG ?=/' internal/gen/python.go
