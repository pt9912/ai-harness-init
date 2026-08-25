#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_KeineErfassungOhneTraeger
#
# HEBT DIE KOPPLUNG AUF: der Erfassungs-Block wandert unbedingt in die emittierte
# .claude/settings.json, auch wenn der Traeger nicht abgelegt werden konnte.
#
# Das ist das woertlich benannte Gegenbeispiel zu LH-QA-01 aus LH-FA-10: „kann der
# Traeger nicht emittiert werden, wird begruendet NICHTS abgelegt — kein Hook, der auf
# ein fehlendes Programm zeigt" (ADR-0022 Festlegung 5a nennt es als das Rot, ohne das
# die Zusage eine Absicht bleibt). Unter dieser Mutation truege ein Ziel ohne Traeger
# drei Hook-Eintraege auf einen Wrapper, den es ebenfalls nicht hat — jeder Tool-Call
# liefe in einen Hook, dessen Programm fehlt.
set -euo pipefail
sed -i 's/enforceContent(f.src, captured)/enforceContent(f.src, true)/' internal/emit/enforce.go
