#!/usr/bin/env bash
# files: harness/tools/register-ausgang.sh
# expect: register-ausgang: offen ueber der Schwelle -> exit 1, Meldung nennt Eintrag, Zahl und Stand
#
# Nimmt `offen` in die Menge der Ausgaenge auf. Ein Eintrag ueber der 3x-Schwelle ohne Ausgang
# geht dann still durch — die Zusage des Waechters faellt ganz.
#
# Rot wird in test/register-ausgang.bats der genannte Fall; derselbe Zweig faerbt auch
# „das erste Wort entscheidet …" rot, der die Wort-Zerlegung bindet.
set -euo pipefail
sed -i 's/verkörpert|geplant|gestrichen) ;;/verkörpert|geplant|gestrichen|offen) ;;/' harness/tools/register-ausgang.sh
