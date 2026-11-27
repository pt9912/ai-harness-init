#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: fastpfad: Teildrift meldet genau die gedrifteten Checks
# verify: test-bats
#
# ENTKOPPELT DIE KLASSIFIKATION VON DER GLEICHHEIT: die gedeckt-Zeile
# (`… # gedeckt`) entfällt aus deck_oder_drift — jeder formale Stempel gilt als
# Drift, auch wenn sein Wert deckt. Der Bericht mit einer gedeckten und zwei
# gedrifteten Zeilen meldet dann drei Checks: der Test `fastpfad: Teildrift meldet
# genau die gedrifteten Checks` sieht die gedeckte Zeile (mutate-greift) in der
# Meldung des Teildrift-Laufs und faerbt rot — der SKIP-Anteil behauptete Laeufe,
# die der Deckung nach nichts brauchten.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: Aufrufer ist das Make-Target `gates` ueber
# `bash harness/tools/gates-fast.sh`; die bats-Stufe faehrt dieselbe Klassifikation
# ueber `--entscheide`, denselben Einstieg wie der Lauf.
#
# ERWARTETER ROT-GRUND: genau jener Test; die fail-closed-Zustaende (leer, unformal)
# fallen weiter in Exit 1 und faerben ihre Tests nicht mit.
set -euo pipefail
sed -i '/# gedeckt$/d' harness/tools/gates-fast.sh
