#!/usr/bin/env bash
# files: cmd/ai-harness-init/version.go
# expect: TestVersionMeldetDieInjizierteFassung
# verify: test-go
#
# Meldet einen FESTEN Wert statt der Injektion. Das ist die Variante, unter der
# jede Ausgabe gleich aussieht, gleichgueltig welcher Tag uebergeben wurde — die
# Fassung haette aufgehört, der uebergebenen Release-Entscheidung zu folgen
# (ADR-0063 Festlegung 1: der Bau meldet den Wert, den sein Injektions-Schritt
# uebergeben bekam). Der Waechter haelt die Ausgabe an den uebergebenen Wert; der
# ldflags-Weg selbst haelt am Bau (test/mutations/401).
set -euo pipefail
sed -i 's|fmt.Fprintln(stdout, fassung)|fmt.Fprintln(stdout, "v0.0.0-fest")|' cmd/ai-harness-init/version.go