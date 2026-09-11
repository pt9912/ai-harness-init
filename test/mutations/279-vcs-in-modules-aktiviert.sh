#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs ist NICHT in modules: aktiviert (braucht eine Range, LH-QA-01)
#
# Nimmt `vcs` in die `modules:`-Liste auf. Das Modul braucht eine Commit-Range; ein
# hermetischer `docs-check`-Lauf ohne Range liefe damit ins Leere oder bricht ab, statt den
# ADR-Bestand netzlos zu pruefen (LH-QA-01: keine halluzinierten Gates). Aktiviert wird `vcs`
# ausschliesslich ueber `make adr-immutable`/`make doc-immutable` mit einer expliziten RANGE.
#
# Das Muster ankert auf der schliessenden Klammer der `modules:`-Zeile, nicht auf ihrem vollen
# Inhalt -- ein weiteres, vor `vcs` aktiviertes Modul zieht dem Zahn nicht die Zaehne.
set -euo pipefail
sed -i '/^modules: \[/ s/\]$/, vcs]/' .d-check.yml
