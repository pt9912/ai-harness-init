#!/usr/bin/env bash
# files: .d-check.yml
# expect: TestRepoKonfiguration_BegruendungNenntJedenBaum
# verify: test-go
#
# DIE BEGRUENDUNG EINES REFERENZ-WEITEN EINTRAGS VERLIERT EINEN BAUM: der Kommentar ueber
# docs/plan/planning/observations.md unter codepaths.ignore-refs nennt das Beobachtungs-Register
# nicht mehr, obwohl der Eintrag dort eine Inline-Code-Nennung stumm schaltet. Der Waechter liest
# die reale .d-check.yml gegen den realen Baum und meldet:
#   codepaths.ignore-refs docs/plan/planning/observations.md (Zeile …): die Begruendung nennt
#   docs/plan/planning/observations/ nicht — der Schluessel trifft dort …
set -euo pipefail
sed -i 's|^    # docs/plan/planning/observations/ (eine Beobachtung beschreibt den Wegfall der Datei)\.$|    # (eine Beobachtung beschreibt den Wegfall der Datei).|' .d-check.yml
