#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: head-allow traegt die gelebte Link-Form, nicht die bare Werkzeug-Vorgabe
#
# Setzt `head-allow` auf die von `d-check --print-config` vorgeschlagene bare Kennungsform
# zurueck (`Superseded by ADR-NNNN` ohne eckige Klammern). Der Bestand dieses Repos lebt die
# Link-Form (`Superseded by [ADR-NNNN](NNNN-titel.md)`, gemessen an den zwei superseded ADRs) —
# mit der baren Vorgabe faerbt der erlaubte Supersede-Uebergang faelschlich rot, statt gruen zu
# bleiben (AGENTS.md 3.4 verlangt genau diesen Uebergang als Korrekturweg).
set -euo pipefail
sed -i "s/^  head-allow: '.*'\$/  head-allow: '^\\\\*\\\\*Status:\\\\*\\\\* (Accepted|Superseded by ADR-[0-9]{4})'/" .d-check.yml
