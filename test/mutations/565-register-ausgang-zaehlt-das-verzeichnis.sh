#!/usr/bin/env bash
# files: harness/tools/register-ausgang.sh
# expect: register-ausgang: gezaehlt werden Dateien evidence/*.md, kein Nicht-.md und kein Unterverzeichnis
#
# Laesst die Existenz eines Eintrags unter evidence/ als Beleg zaehlen statt nur einer Datei —
# ein Verzeichnis namens `*.md` hebt den Zaehler dann ueber die Schwelle (ADR-0069
# Folgepflicht 2: gezaehlt werden Dateien).
#
# Rot wird allein der genannte Fall in test/register-ausgang.bats. Anker in DOPPELTEN
# Anfuehrungszeichen (SC2016, s. test/mutations/117).
set -euo pipefail
sed -i "s/\[ -f \"\\\$f\" \] && belege/[ -e \"\$f\" ] \\&\\& belege/" harness/tools/register-ausgang.sh
