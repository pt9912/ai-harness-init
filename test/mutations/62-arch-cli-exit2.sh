#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangUnknownArch
#
# Schwaecht callExitCode: das ODER der beiden Aufruf-Fehler-Zweige (`&ule) || errors.As`)
# wird zum UND (`&& errors.As`). Dann muss ein Fehler BEIDE Typen zugleich sein, um Exit 2
# zu ergeben — kein realer Fehler ist das, also faellt UnknownArchError (und UnknownLangError)
# auf den Emit-Code 1 zurueck. `add-lang … --arch <unbekannt>` liefert dann 1 statt 2
# (slice-045b Negative-AC). Beide errors.As bleiben GENUTZT -> kompiliert (kein „unused"-
# Compile-Rot aus falschem Grund); der Waechter faellt an der Assertion. SC2016-clean.
set -euo pipefail
sed -i 's/&ule) || errors.As/\&ule) \&\& errors.As/' cmd/ai-harness-init/main.go
