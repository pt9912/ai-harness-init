#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Die Gegenrichtung der drei Faelle davor: ein SINGLETON wird zusaetzlich in
# isRecurring aufgenommen und damit NICHT mehr emittiert. Ziel ist
# AGENTS.template.md, NICHT MEHR observations.template.md (Plural) — die
# Vorlage, an der dieser Fall urspruenglich haengte, ist mit dem v6.0.0-Tausch
# umbenannt UND umklassifiziert: "observation.template.md" (Singular) steht seither
# SELBST im ersten isRecurring-case (ADR-0034/slice-182). Eine Mutation, die den
# alten Pluralnamen einfuegt, traefe keinen realen Datei-Basename mehr und
# TestTemplates_EmittierterBestandVollstaendig bliebe unveraendert gruen — der
# Fall haette lautlos seine Zaehne verloren. Eine Mutation, die "observation.template.md"
# (Singular) ein zweites Mal einfuegt, waere ein DUPLICATE-CASE-Compile-Fehler
# statt eines Testfalls: go test liefe gar nicht erst an, keine "--- FAIL:"-Zeile
# mit dem erwarteten Testnamen entstuende, und Bedingung 4 (rot am richtigen Grund)
# schluege fehl.
#
# AGENTS.template.md ist unbeteiligt vom Register-Umbau, real ein Singleton (die
# want-Liste in TestTemplates_EmittierterBestandVollstaendig fuehrt "AGENTS.md"),
# und kein Basename kollidiert mit einem vorhandenen isRecurring-Eintrag — die
# Mutation ist damit ein regulaerer, kompilierender Zusatz-Case statt eines
# Duplikats. Nach der Mutation faellt AGENTS.template.md unter isRecurring und wird
# NICHT mehr als Singleton emittiert: der Ist-Bestand verliert "AGENTS.md" gegen die
# `want`-Liste, und der Test faellt genau dort (t.Errorf, "emittierter Bestand
# weicht ab", diff zeigt AGENTS.md fehlend). Kompiliert weiter.
set -euo pipefail
sed -i 's/"welle-results.template.md", "MR-NNN-titel.template.md":/"welle-results.template.md", "MR-NNN-titel.template.md", "AGENTS.template.md":/' internal/emit/templates.go
