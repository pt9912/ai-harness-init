#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestCommitMsgAnweisung_NenntTraegerUndAktivierung
# verify: test-go
#
# NIMMT DEM ANWEISUNGSSATZ DIE AKTIVIERUNG: der Traeger wird im Ziel noch genannt,
# aber kein Wort sagt mehr, welcher Schritt `core.hooksPath` setzt.
#
# Damit haengt die Zusage an einer Konvention ohne Traeger: der Hook liegt versioniert
# im Ziel und schweigt, bis jemand die lokale Konfiguration setzt — und wer den Satz
# liest, erfaehrt nicht, dass er sie setzen kann. Dieselbe Klasse wie Fall 339
# (Anleitung nennt ein Ziel, das es nicht gibt), eine Ebene tiefer.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Text der
# emittierten Vorlage, nicht ihre Wirkung — ein `make full-smoke` liest denselben Text
# im gebootstrappten Ziel, kostet aber den vollen E2E-Lauf.
set -euo pipefail
sed -i '/make hooks-install/d' internal/emit/templates/commands/implement-slice.md
