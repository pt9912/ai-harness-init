#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_HexagonalRolesExplicit
#
# Nimmt der Schicht `driven` ihre EXPLIZITE Rolle (die `role: adapter`-Zeile direkt unter
# ihrem Glob). Sie sieht wie Redundanz aus — der Verzeichnisname sagt doch schon, was das
# ist —, aber die Namens-Inferenz von a-check kennt nur core/ports/adapters/application/app:
# `driven` inferiert NICHTS. Ohne die Zeile ist die Schicht bloss kanten-geprueft, und
# `lateral-adapter` (die tragende Regel dieses Layouts, ADR-0010) faellt lautlos aus —
# das Gate bleibt gruen, waehrend die Regel weg ist (LH-QA-01).
set -euo pipefail
sed -i '/globs: \["internal\/adapter\/driven\/\*\*"\]/{n;d}' internal/gen/golang.go
