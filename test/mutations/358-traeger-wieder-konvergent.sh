#!/usr/bin/env bash
# files: internal/emit/commitmsg.go
# expect: TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
#
# DER TRAEGER WIRD WIEDER KONVERGENT ABGELEGT: der eine Eintrag, der skip-if-present traegt,
# wechselt die Klasse. Ein Ziel, das an diesem Pfad seine eigene Kennungs-Zusage fuehrt —
# Name von git fixiert, Verzeichnis des Repos —, verliert seine Datei damit lautlos und
# steht nach dem Lauf schlechter da als vorher.
#
# Getroffen ist die Klasse im Eintrag, nicht der Writer: der Eintrag ist die eine Stelle, an
# der die Klasse eines Pfades steht (AGENTS.md §3.6 — der Zahn misst die Verdrahtung, nicht
# eine zweite Liste daneben).
set -euo pipefail
sed -i 's/class: SkipIfPresent/class: Konvergent/' internal/emit/commitmsg.go
