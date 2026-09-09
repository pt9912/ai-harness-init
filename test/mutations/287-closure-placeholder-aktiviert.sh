#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure.placeholder bleibt aus (kein escapter Vorlagen-Fund als Befund)
#
# Setzt `placeholder: true` unter `closure:` — die in slice-129 verworfene Bedingung
# (harness/README.md: der einzige damit erreichbare Fund ist eine escapte Vorlagen-Syntax in
# einer `done/`-Datei, kein unausgefuellter Rumpf). `docs-check` selbst faerbt darauf einen
# Bestand rot, der nichts falsch macht; dieser Waechter haelt die Entscheidung ohne einen
# Docker-Lauf.
set -euo pipefail
sed -i "s/^    dir: docs\/plan\/planning\/done\$/    dir: docs\/plan\/planning\/done\n    placeholder: true/" .d-check.yml
