#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: status-line markiert die Statuszeile fuer head-allow
#
# Entfernt den Schluessel `status-line` aus dem `vcs:`-Block. Ohne ihn faellt die Statuszeile
# einer angenommenen ADR unter die volle Kern-Unveraenderlichkeit statt unter `head-allow` —
# der erlaubte Supersede-Uebergang faerbt dann faelschlich rot (gemessen: 0 Befund(e) mit
# `status-line`, 1 Befund(e) ohne, bei identischem, erlaubtem Uebergang).
set -euo pipefail
sed -i "/^  status-line: /d" .d-check.yml
