#!/usr/bin/env bash
# files: harness/tools/full-smoke.sh
# expect: GO_VERSION-Fallback in full-smoke.sh == Makefile-Pin
#
# Wie Fall 668, fuer den Fallback in full-smoke.sh: ein Pin-Zug laesst ihn auf dem Vorwert
# stehen, und allein der Kopplungs-Fall in test/pin-fallbacks.bats wird rot (LH-QA-02).
set -euo pipefail
sed -i 's/^\(GO_VERSION="[$]{GO_VERSION:-\)[0-9.]*}"/\10.0.0}"/' harness/tools/full-smoke.sh
