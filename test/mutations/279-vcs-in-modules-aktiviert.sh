#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs ist NICHT in modules: aktiviert (braucht eine Range, LH-QA-01)
#
# Nimmt `vcs` in die `modules:`-Liste auf. Das Modul braucht eine Commit-Range; ein
# hermetischer `docs-check`-Lauf ohne Range liefe damit ins Leere oder bricht ab, statt den
# ADR-Bestand netzlos zu pruefen (LH-QA-01: keine halluzinierten Gates). Aktiviert wird `vcs`
# ausschliesslich ueber `make adr-immutable`/`make doc-immutable` mit einer expliziten RANGE.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, codepaths, spans, planning\]$/modules: [links, anchors, ids, matrix, codepaths, spans, planning, vcs]/' .d-check.yml
