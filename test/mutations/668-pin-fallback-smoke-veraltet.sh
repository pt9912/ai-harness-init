#!/usr/bin/env bash
# files: harness/tools/smoke.sh
# expect: GO_VERSION-Fallback in smoke.sh == Makefile-Pin
#
# Der Fallback `GO_VERSION="${GO_VERSION:-<wert>}"` bleibt bei einem Pin-Zug auf dem Vorwert
# stehen. Match generisch auf den Wert ([0-9.]*), damit der Fall bei jedem Pin-Zug greift;
# rot wird allein der Kopplungs-Fall in test/pin-fallbacks.bats (LH-QA-02).
set -euo pipefail
sed -i 's/^\(GO_VERSION="[$]{GO_VERSION:-\)[0-9.]*}"/\10.0.0}"/' harness/tools/smoke.sh
