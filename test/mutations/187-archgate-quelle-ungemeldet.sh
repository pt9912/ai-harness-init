#!/usr/bin/env bash
# files: internal/emit/erfassung_test.go
# expect: TestErfassung_KeinArchGateInZielQuellen
# verify: test-go
#
# LAESST EINE QUELLE UNTER DEM ARCH-GATE-PRAEFIX IN DIE GELESENE ZIEL-QUELLEN-MENGE
# WACHSEN, OHNE DASS DIE ZWEITE GRENZE IM KOMMENTAR VON makeQuellenDesZiels DAVON WEISS.
#
# Die zweite GRENZE (makeQuellenDesZiels sieht das Arch-Gate-Fragment nie, weil der hier
# gefahrene Emit flach ist) stuende dann im Kommentar, waere aber falsch — genau der
# Fall, den DoD (3) mit einem Go-Test statt einer Behauptung im Kommentar schliesst: die
# Grenze wird gegen den TATSAECHLICH gelesenen Satz gehalten, nicht nur benannt.
set -euo pipefail
sed -i '/^\tif len(quellen) < 4 {$/i\	quellen["harness/mk/arch-demo.mk"] = "x"' internal/emit/erfassung_test.go
