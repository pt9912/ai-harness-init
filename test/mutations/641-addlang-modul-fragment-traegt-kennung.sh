#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# DAS MODUL-FRAGMENT DES ARCHITEKTUR-GATES, DAS NUR add-lang AN EINEM UNTERVERZEICHNIS
# SCHREIBT, TRAEGT EINE KENNUNG DIESES REPOS in seinem Hilfetext. Ein Bootstrap am Repo-Root
# erreicht diesen Zweig nicht (path == "."); gelesen wird er allein ueber die Variante
# sprachlos-add-lang und meldet:
#   harness/mk/arch-apps-go.mk: emittiert ADR-0009 (ebenso arch-apps-kt.mk)
# Gegenprobe: ohne die Variante sprachlos-add-lang bleibt der Fall gruen (LH-QA-01).
set -euo pipefail
sed -i 's|(a-check, netzlos, read-only)\\n" +$|(a-check, netzlos, read-only, ADR-0009)\\n" +|' internal/emit/archgate.go
grep -q 'read-only, ADR-0009' internal/emit/archgate.go
