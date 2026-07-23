#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestGenerate_CppTestNetzlos
#
# In den generierten cpp-Test wird ein externes Framework (gtest) gezogen -> nicht mehr
# netzlos (LH-QA-03: kein FetchContent/find_package/Framework-Include). Der Netzlos-
# Waechter muss rot werden.
set -euo pipefail
sed -i 's|#include <cstdlib>|#include <gtest/gtest.h>|' internal/gen/cpp.go
