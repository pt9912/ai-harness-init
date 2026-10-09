#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_ReviewsBleibtKommentarBlock
#
# Setzt die Pin-Fassung in der Prosa des reviews-Blocks der emittierten .d-check.yml auf
# einen Tag, den emit.DefaultImage nicht fuehrt: die Aussagen ueber das Werkzeug stehen dann
# neben einem Pin, an dem sie nicht gemessen sind.
set -euo pipefail
sed -i -E 's/^(# ohne ihn oeffnet das Modul keine Datei\. Am Pin )v[0-9]+\.[0-9]+\.[0-9]+ /\1v0.0.1 /' \
  internal/emit/templates/d-check.yml
