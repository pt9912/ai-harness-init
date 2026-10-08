#!/usr/bin/env bash
# files: internal/ausnahmegrund/ausnahmegrund.go
# expect: TestEintraege_UnbekannteFormFailClosed
# verify: test-go
#
# DER PARSER UEBERGEHT EINE UNBEKANNTE FORM IN EINER BLOCK-LISTE STILL: eine Zeile, die zur Liste
# gehoert und kein gelesener Wert ist (verschachteltes Item, Fortsetzungszeile), schliesst die
# Liste, statt einen Fehler zu liefern. Der Eintrag fehlt dann in der Liste, und der Waechter
# misst ihn nicht. Der Fall meldet:
#   verschachteltes Item: erwartet Fehler mit "codepaths.ignore-refs (Zeile 4)", bekommen err=<nil> …
set -euo pipefail
sed -i 's|^\t\treturn r\.fehler(i, r\.blockSchl)$|\t\tr.blockEnde()\n\t\treturn nil|' internal/ausnahmegrund/ausnahmegrund.go
