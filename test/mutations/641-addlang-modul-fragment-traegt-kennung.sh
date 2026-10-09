#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# DAS MODUL-FRAGMENT DES ARCHITEKTUR-GATES, DAS NUR add-lang AN EINEM UNTERVERZEICHNIS
# SCHREIBT, TRAEGT EINE KENNUNG DIESES REPOS in seinem Hilfetext. Ein Bootstrap am Repo-Root
# erreicht diesen Zweig nicht (path == "."); am Ziel gelesen wird er allein ueber die
# Variante sprachlos-add-lang:
#   harness/mk/arch-apps-go.mk: emittiert ADR-0009 (ebenso arch-apps-kt.mk)
# Die Mutation faerbt zwei Tests rot: die Kennung steht in einem Go-Literal, das auch
# TestTraegerMeldungenTragenKeineKennung liest (internal/emit/archgate.go: ADR-0009).
# `# expect:` nennt einen der zwei, keine alleinige Bindung. Gegenprobe: ohne die Variante
# sprachlos-add-lang wird der genannte Test gruen, die Suite bleibt ueber den Literal-
# Waechter rot — was die Variante allein traegt (Text aus eingebetteten Vorlagen am
# Unterverzeichnis), belegt dieser Fall nicht (LH-QA-01).
set -euo pipefail
sed -i 's|(a-check, netzlos, read-only)\\n" +$|(a-check, netzlos, read-only, ADR-0009)\\n" +|' internal/emit/archgate.go
grep -q 'read-only, ADR-0009' internal/emit/archgate.go
