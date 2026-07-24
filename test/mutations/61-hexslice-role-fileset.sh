#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_GoHexsliceProfile_FileSet
#
# Entfernt die Domain-Rolle-Datei aus goRole (die Map-Zeile `… greeting.go: goHexDomain,`):
# das komponierte hexSlice-Skelett verliert dann internal/hexagon/domain/example/greeting.go,
# sein Datei-Satz weicht ab. Ohne den exakten Datei-Satz-Anker
# TestGenerate_GoHexsliceProfile_FileSet (slice-045a, ADR-0009) koennte eine Schicht-Datei
# still aus dem Layout fallen — genau die Klasse, die slice-044 fuer flat verankerte, hier
# fuer hexslice. Match `goHexDomain,` (mit Komma) trifft NUR die Map-Zeile, nicht die
# const-Definition (`goHexDomain =`) noch die Test-Rolle (`goHexDomainTest,`); SC2016-clean.
set -euo pipefail
sed -i '/goHexDomain,/d' internal/gen/golang.go
