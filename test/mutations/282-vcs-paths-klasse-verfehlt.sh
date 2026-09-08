#!/usr/bin/env bash
# files: .d-check.yml
# expect: vcs: schuetzt genau die ADR-Datei-Klasse
#
# Weitet `paths` von der ADR-Datei-Klasse auf alle Markdown-Dateien der Planungs-Ablage. Ein
# `paths`, das die Klasse verfehlt, macht das Modul still ueber einer Menge, die es nicht pruefen
# soll — die stille Fehlform, die der Slice-Plan (slice-127 §6) benennt und die kein rot faerbender
# Lauf zeigt, weil sie zu viel statt zu wenig deckt.
set -euo pipefail
sed -i 's/^  paths: \["docs\/plan\/adr\/\[0-9\]\*\.md"\]$/  paths: ["docs\/plan\/**\/*.md"]/' .d-check.yml
