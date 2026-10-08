#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_ReviewsBleibtKommentarBlock
#
# Nimmt dem reviews-Block der emittierten .d-check.yml die fuehrenden #: der Block steht
# unkommentiert, das Modul bleibt ausserhalb von modules:. docs-check im Ziel bleibt dabei
# gruen; der Waechter faerbt rot.
set -euo pipefail
sed -i \
  -e 's/^# reviews:$/reviews:/' \
  -e 's/^#   done-dir: docs\/plan\/planning\/done$/  done-dir: docs\/plan\/planning\/done/' \
  -e 's/^#   reviews-dir: docs\/reviews$/  reviews-dir: docs\/reviews/' \
  internal/emit/templates/d-check.yml
