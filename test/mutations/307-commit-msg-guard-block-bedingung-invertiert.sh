#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-commit-msg-guard.sh
# expect: hook: Pruef-Instanz FAIL (Kennung fehlt) -> BLOCK mit Dateiname in der Begruendung
#
# Kippt die Block-Bedingung: `check_rc -ne 0` (Pruef-Instanz ist gescheitert,
# die Message-Datei traegt keine Kennung) wird zu `check_rc -eq 0`
# (Pruef-Instanz war ERFOLGREICH). Der Hook blockt danach genau die Commits,
# deren Message-Datei EINE Kennung traegt, und laesst kennungslose durch —
# die Kennungs-Pruefung ist damit wirkungslos entfernt, ohne dass der Aufruf
# selbst (Match, Datei-Existenz, Checker-Aufruf) sich aendert.
set -euo pipefail
sed -i 's/if \[ "\$check_rc" -ne 0 \]; then/if [ "$check_rc" -eq 0 ]; then/' .claude/hooks/pretooluse-commit-msg-guard.sh
