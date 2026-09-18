#!/usr/bin/env bash
# files: internal/emit/baumaussage.go
# expect: jeder Regelblock des gepinnten Baums traegt einen Inventur-Eintrag
# verify: test-bats
#
# NIMMT EINEM REGELBLOCK DES GEPINNTEN BAUMS SEINEN INVENTUR-EINTRAG: die Inventur deckt
# danach einen Block weniger, als das regelwerk/-Verzeichnis fuehrt.
#
# WAS DAS MISST: die Abdeckung gegen den NENNER. Der fehlende Eintrag sieht aus wie "kein
# Traeger" und ist "nicht geprueft" — genau die Luecke, die eine kuratierte Liste gegenueber
# einem Inventar hat. Die bats-Stufe ist die schmalste ausreichende: der Nenner liegt unter
# .harness/, das der Docker-Build-Kontext der go-Stufe ausschliesst.
set -euo pipefail
sed -i '/{Modul: "modul-16-produktiver-betrieb.md"/,+1d' internal/emit/baumaussage.go
