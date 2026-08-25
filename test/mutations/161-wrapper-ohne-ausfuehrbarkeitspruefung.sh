#!/usr/bin/env bash
# files: internal/emit/templates/enforce/span-emit.sh
# expect: wrapper: fehlender Traeger -> Exit 0 und keine Ausgabe
# verify: test-bats
#
# NIMMT DEM WRAPPER DIE AUSFUEHRBARKEITS-PRUEFUNG: er startet den ersten Kandidaten,
# auch wenn dort nichts liegt.
#
# Genau das ist der Fall, fuer den es den Wrapper gibt (ADR-0022 Festlegung 5b): ein
# frischer Klon des Adopter-Repos hat den gitignorierten Traeger nicht. Ohne die
# Pruefung meldet die Shell je Tool-Call „No such file or directory" — der Beobachter
# redet in einen Lauf hinein, den er nur beobachten soll.
set -euo pipefail
sed -i "s/if \[ -x \"\$carrier\" \]; then/if true; then/" internal/emit/templates/enforce/span-emit.sh
