#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenUnterReviewsSchreibtNurDieLinkForm
# verify: test-go
#
# LAESST DIE LINK-REGEL UEBER DIE LINK-GRENZE HINWEG SUCHEN: der Praefix-Teil des
# Musters in praefixLinkRE darf danach ein `)` ueberqueren (`.*` statt
# `[^)#\n]*`). Bei mehreren Links in einer Zeile greift die Regel dann ueber den
# ersten Link hinweg bis zum letzten Treffer, und der erste Link bleibt auf dem
# alten Ort stehen.
#
# WAS DAS MISST: der Fall traegt drei Links in einer Zeile, einen fremden
# dazwischen, und liest den ganzen Dateiinhalt und den Zaehler. Die Faelle mit je
# einem Link pro Zeile faerben bei dieser Mutation nicht.
#
# Der Anker steht genau einmal in refs.go, als Praefix-Teil des Musters
# (grep -cF '(?:[^)#\n]*[^A-Za-z0-9_)#\n-])?' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~[[]^)#\\n]\*[[]^A-Za-z0-9_)#\\n-]~.*[^A-Za-z0-9_)#\\n-]~' internal/archive/refs.go
