#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_KeinPlatzhalterLinkImEmittiertenSatz
#
# Der Singleton-Emit laesst die Platzhalter-Link-Neutralisierung aus. Die
# emittierten Dokumente tragen dann wieder Links, deren Ziel-Pfad einen
# <…>-Platzhalter fuehrt — im frisch gebootstrappten Repo zeigt jeder davon auf
# keine Datei, und das emittierte docs-check meldet ihn (LH-FA-02: der emittierte
# Stand ist out-of-the-box gate-sicher).
set -euo pipefail
sed -i '/body = NeutralizePlaceholderLinks(body)/d' internal/emit/templates.go
