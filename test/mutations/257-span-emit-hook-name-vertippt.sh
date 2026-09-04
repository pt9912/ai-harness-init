#!/usr/bin/env bash
# files: .claude/settings.json
# expect: jedes Unterkommando hinter dem Traeger in .claude/settings.json steht im Dispatch von main()
# verify: test-bats
#
# VERTIPPT DEN UNTERKOMMANDO-NAMEN IM HOOK-KANAL: die Hooks dieses Repos rufen
# den Traeger direkt und geben ihm danach `span-emitt`. Der Dispatch in main()
# fuehrt diesen Namen nicht, also faellt der Aufruf in den Init-Pfad und endet
# dort mit Exit 2 — dem Wert, mit dem ein Hook blockiert.
#
# DIE KLEMME AUS ADR-0011 FESTLEGUNG 6 DECKT DAS NICHT. Sie sitzt in spanEmit()
# und klemmt, was dort ankommt; ein Name, der spanEmit() nie erreicht, liegt vor
# ihr. Das emittierte Repo faengt dieselbe Lage mit `|| true` im Wrapper-Skript
# ab — dieses Repo hat keinen Wrapper, und darum haelt hier dieser Fall.
#
# Das Literal steht an zwei Stellen, und nichts ausser diesem Fall haelt sie
# aneinander: `make comment-claims` fuehrt `.claude/settings.json` nicht in
# seinem Pruefbereich, `shell-lint` liest die Datei nicht, und keine Go-Stufe
# oeffnet sie.
set -euo pipefail
sed -i 's,ai-harness-init span-emit,ai-harness-init span-emitt,' .claude/settings.json
