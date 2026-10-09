#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_ReviewsBleibtKommentarBlock
#
# Streicht match: name aus dem reviews-Block der emittierten .d-check.yml: ein Adopter, der
# den Block ohne # uebernimmt, bekommt fuer einen Slice-Plan mit Kennung in Namens-Form
# review-missing, auch wenn sein Report vorliegt.
set -euo pipefail
sed -i '/^#   match: name$/d' internal/emit/templates/d-check.yml
