#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: docs/reviews: mehrere Links in einer Zeile werden je fuer sich nachgezogen
# verify: test-bats
#
# LAESST DIE LINK-REGEL UEBER DIE LINK-GRENZE HINWEG SUCHEN: der Praefix-Teil des
# Musters in rewrite_incoming_links_in_file darf danach ein `)` ueberqueren
# (`.*` statt `[^)#]*`). Bei mehreren Links in einer Zeile greift die Regel dann
# ueber den ersten Link hinweg bis zum letzten Treffer, und der erste Link bleibt auf
# dem alten Ort stehen.
#
# WAS DAS MISST: der Fall traegt drei Links auf den bewegten Slice und einen fremden
# in einer Zeile, dazu einen Link unmittelbar hinter einem Code-Span, und liest
# den ganzen Dateiinhalt und den Zaehler. Die Faelle mit je einem Link pro Zeile
# faerben bei dieser Mutation nicht.
#
# Der Anker steht genau einmal im Skript, als Praefix-Teil des Musters
# (grep -cF '[^)#]*[^A-Za-z0-9_)#-]' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~[[]^)#]\*[[]^A-Za-z0-9_)#-]~.*[^A-Za-z0-9_)#-]~' harness/tools/slice-mv.sh
