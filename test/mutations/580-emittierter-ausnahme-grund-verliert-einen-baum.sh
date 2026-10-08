#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestEmittierteKonfiguration_BegruendungNenntJedenBaum
# verify: test-go
#
# DIE EMITTIERTE BEGRUENDUNG VON scan.ignore VERLIERT EINEN BAUM: der Kommentar nennt die
# Reviewer-Skills unter .harness/skills/ nicht mehr, obwohl .harness/** sie im Ziel aus dem
# Doc-Gate nimmt. Der Waechter faehrt den realen Bootstrap und meldet:
#   scan.ignore .harness/** (Zeile …): die Begruendung nennt .harness/skills/ nicht — der
#   Schluessel trifft dort .harness/skills/closure-note-reviewer.md
set -euo pipefail
sed -i 's|^  # dieses Repo nicht schreibt) und \.harness/skills/ (die Reviewer-Skills; sie gehoeren nach dem$|  # dieses Repo nicht schreibt) und die Reviewer-Skills (sie gehoeren nach dem|' internal/emit/templates/d-check.yml
