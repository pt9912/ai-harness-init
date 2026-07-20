#!/usr/bin/env bash
# files: internal/emit/templates/baseline-verify.sh
# expect: emittiert: eingelegter SYMLINK
#
# Der Ist-Bestand wird wieder mit `-type f` gelesen. Ein eingelegter Symlink ist
# dann weder gelistet noch sichtbar — beide Achsen melden gruen (Befund 022a H1).
set -euo pipefail
perl -pi -e 's/find \. ! -type d/find . -type f/' internal/emit/templates/baseline-verify.sh
