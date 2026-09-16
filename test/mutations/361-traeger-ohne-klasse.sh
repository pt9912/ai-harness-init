#!/usr/bin/env bash
# files: internal/emit/commitmsg.go
# expect: TestEnforce_IdempotenzKlasseJePfad
#
# EIN EINTRAG OHNE KLASSE: der Traeger-Pfad traegt danach keinen der beiden Werte mehr. Der
# Emit faellt fail-closed aus, statt den Pfad still als konvergent abzulegen — genau der
# Zweifelsfall, den die Tabelle in ADR-0007 Festlegung 3 mit "im Zweifel skip-if-present"
# entscheidet und den eine stille Voreinstellung ueberspielen wuerde.
set -euo pipefail
sed -i 's/class: SkipIfPresent/class: klasseUnbestimmt/' internal/emit/commitmsg.go
