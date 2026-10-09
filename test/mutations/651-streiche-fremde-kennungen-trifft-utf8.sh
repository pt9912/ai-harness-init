#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestStreicheFremdeKennungenTrifftNurDieRegister
# verify: test-go
#
# DIE STREICHUNG IM --print-mk-FRAGMENT TRIFFT JEDE GROSSBUCHSTABEN-ZIFFER-FORM, NICHT NUR
# DIE REGISTER DER NACHBAR-WERKZEUGE: `(UTF-8)`, `(ISO-8601)`, `(SHA-256)` fallen still aus
# dem Kommentar. Der Waechter meldet:
#   StreicheFremdeKennungen("# Ausgabe als Text (UTF-8).") = "# Ausgabe als Text." …
# Gegenprobe: ohne die UTF-8-/ISO-8601-/SHA-256-Zeilen im Test bleibt der Fall gruen
# (LH-QA-01).
sed -i '/^const fremdeKennung = /s#(?:(?:DC|AC)(?:-\[A-Z\]+)+-\[0-9\]+|ADR-\[0-9\]{4}|#(?:[A-Z]{2,}(?:-[A-Z]+)*-[0-9]+|#' internal/emit/emit.go
grep -qF '(?:[A-Z]{2,}(?:-[A-Z]+)*-[0-9]+|slice-' internal/emit/emit.go
