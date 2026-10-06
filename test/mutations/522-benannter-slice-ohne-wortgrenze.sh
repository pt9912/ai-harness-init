#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: rot: ein Mittendrin-Wort ohne Trenner links von slice- ist keine Kennung
# verify: test-bats
#
# DIE ZEILE `named_slice=` VERLIERT IHRE LINKE WORTGRENZE: `noslice-foo` und
# `x_slice-bar` gelten wieder als Kennung. Der Fall der Mittendrin-Woerter faellt.
#
# DER PATCH SITZT AUF DER AUSFUEHRENDEN ZEILE (Zuweisung), nicht auf der Prosa im Kopf.
set -euo pipefail
sed -i "s@^named_slice='(^|\[^\[:alnum:\]_-\])@named_slice='@" internal/emit/templates/enforce/commit-msg-traceability.sh
