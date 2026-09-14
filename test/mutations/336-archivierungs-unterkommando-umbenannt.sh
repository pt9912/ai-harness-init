#!/usr/bin/env bash
# files: internal/emit/templates/enforce/archivierung.mk
# expect: im emittierten Archivierungs-Fragment steht im Dispatch von main()
# verify: test-bats
#
# BENENNT DAS UNTERKOMMANDO IM AUFRUF UM: das emittierte Fragment gibt dem Traeger
# danach `archive-welle-neu`, waehrend main() weiter `archive-welle` dispatcht.
#
# WAS DAS IM ZIEL BEDEUTET: der Name reist als Zeichenkette in das gebootstrappte
# Repo, wo ihn kein Gate DIESES Repos sieht. Dort faellt der Aufruf in den
# Init-Pfad und endet an der Sperre in run() mit Exit 2 — ein Aufruf, der nichts
# archiviert und dabei aussieht, als haette er es getan.
#
# DAS ZIEL DES FRAGMENTS BLEIBT UNVERAENDERT, und darum trifft dieser Fall allein
# die Namens-Kopplung: die Go-Stufe liest das Ziel `archive-welle` weiterhin, und
# der Mutations-Fall 261 benennt die andere Seite derselben Kopplung — den
# Dispatch in main().
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen wird eine
# Zeichenkette gegen die case-Marken von main(). Ein voller `make full-smoke`-Lauf
# sieht denselben Namen erst, nachdem er den Traeger gebaut und abgelegt hat.
set -euo pipefail
sed -i 's|exec "\$\$c" archive-welle |exec "$$c" archive-welle-neu |' \
	internal/emit/templates/enforce/archivierung.mk
