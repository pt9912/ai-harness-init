#!/usr/bin/env bash
# files: internal/emit/commitmsg.go
# expect: TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
#
# DIE MELDUNG VERLIERT DEN PRUEFPFAD: der belegte Traeger-Pfad bleibt zwar stehen, aber der
# Lauf sagt dem Adopter nicht mehr, was ihm statt seiner Datei bereitliegt. Der stehen
# gebliebene Traeger ist dann von einem, den niemand geprueft hat, nicht zu unterscheiden —
# und die mitgelieferte Pruefung liegt ohne Adresse daneben.
set -euo pipefail
sed -i 's|^const commitMsgBelegterPfadMeldung = .*|const commitMsgBelegterPfadMeldung = ""|' internal/emit/commitmsg.go
