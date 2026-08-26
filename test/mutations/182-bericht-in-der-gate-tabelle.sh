#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestErfassung_KeinEintragInDenGateTabellen
# verify: test-go
#
# TRAEGT DEN BERICHT ALS ZEILE IN EINE GATE-TABELLE DER ZIEL-DOKU EIN.
#
# Ein Eintrag dort BEHAUPTET einen Sensor: wer die Tabelle liest, haelt `span-report`
# fuer etwas, das rot werden kann, und rechnet mit einer Abdeckung, die es nicht gibt
# (LH-QA-01). Die Luecke ist NEU: mit dem Fragment sind die zwei Ziele init-invariant,
# und emit.NeutralizeMakeClaims laesst die Nennung darum stehen, die es vorher zu
# `<make-target>` gemacht haette. Eine Zeile, die ausdruecklich "kein Gate" sagt, waere
# zulaessig — diese sagt es nicht.
#
# DER BACKTICK STEHT IN EINER VARIABLEN: in einfachen Anfuehrungszeichen liest der
# Shell-Lint ihn als beabsichtigte Kommando-Substitution, in doppelten waere er eine.
set -euo pipefail
bt='`'
anker="16. ${bt}make gates${bt} laufen lassen."
zeile="| ${bt}make span-report${bt} | Token-Bilanz je Rolle |"
sed -i "s@^${anker}\$@&\n\n| Target | Zweck |\n|---|---|\n${zeile}@" internal/emit/templates/commands/implement-slice.md
