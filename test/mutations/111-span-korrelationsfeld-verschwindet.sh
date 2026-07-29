#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestMandatoryFieldsAlwaysPresent
#
# Haengt `omitempty` an `branch` — das Feld, an dem der Waechter zuerst VORBEIGESEHEN
# hat.
#
# Fall 110 nimmt sich `tool_use_id` und belegt damit die Mechanik. Dieser Fall belegt
# die REICHWEITE: die Feldliste des Waechters zaehlte 10 der 12 Pflicht-Zeilen aus
# MR-018 auf, und die zwei fehlenden waren genau die, die im Code ein `omitempty`
# trugen (Review-Befund HIGH-2, Verifier V-1). Der Test war damit gruen, WEIL er die
# heutige Implementierung abbildete statt der Zusage — und im git-worktree, wo die
# Ableitung scheitert, verschwanden beide Schluessel lautlos. Ein Auswerter kann dann
# "unbekannt" nicht mehr von "nicht vorhanden" unterscheiden.
set -euo pipefail
sed -i 's@json:"branch"@json:"branch,omitempty"@' internal/span/emit.go
