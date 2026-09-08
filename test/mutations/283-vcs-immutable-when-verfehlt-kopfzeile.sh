#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: immutable-when trifft die Accepted-Kopfzeile
#
# Weitet `immutable-when` von der Accepted-Kopfzeile auf jede Statuszeile (inklusive `Proposed`).
# Ein `immutable-when`, das die Kopfzeile nicht trifft, macht das Modul still ueber Dateien, die
# es nicht schuetzen soll — eine `Proposed`-ADR waere dann ebenso unveraenderlich wie eine
# `Accepted`-ADR, obwohl AGENTS.md 3.4 nur Letztere bindet.
set -euo pipefail
sed -i "s/^  immutable-when: '.*'\$/  immutable-when: '^\\\\*\\\\*Status:\\\\*\\\\*'/" .d-check.yml
