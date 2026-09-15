#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestCommitMsgPruefung_IstDieEinzigeFassungDerMenge
# verify: test-go
#
# LEGT EINE ZWEITE FASSUNG DER KENNUNGS-MENGE AN: die emittierte Doku-Gate-Konfiguration
# bekommt einen `commits:`-Block, waehrend der Traeger seine eigene Regex fuehrt.
#
# Zwei Fassungen derselben Liste driften, und hier faellt der Waechter weg, der sie
# zusammenhaelt: die Pruefung im Commit-Pfad liest die Konfiguration nicht — sie laeuft
# ohne Docker und darf darum kein d-check-Modul aufrufen. In diesem Repo haelt
# test/commit-msg-hook.bats die zwei Fassungen gegen dieselbe Liste; im Ziel gibt es
# diese Kopplung nicht, und genau das sagt harness/README.md §Traceability zu.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der eingebettete
# Inhalt der Vorlage, nicht ein Lauf — der Bootstrap braeuchte Docker und d-check.
set -euo pipefail
sed -i '$a commits:' internal/emit/templates/d-check.yml
