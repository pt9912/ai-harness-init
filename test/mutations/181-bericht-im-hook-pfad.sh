#!/usr/bin/env bash
# files: internal/emit/templates/enforce/settings.json
# expect: TestErfassung_NichtImHookPfad
# verify: test-go
#
# SETZT DEN BERICHT IN DIE HOOK-KONFIGURATION DES ZIELS: der Stop-Hook ruft nach dem
# Gate-Nachweis noch den Leser.
#
# Ein Bericht im Hook-Pfad macht aus einem Leser einen BLOCKIERER: der Hook entscheidet
# ueber den Fortgang des Laufs, den er beobachten soll, und sein Ausgang haengt jetzt an
# einem Kommando, das nichts prueft (ADR-0011 Festlegung 6 klemmt den Erfassungs-Pfad
# genau deshalb auf 0). Die Ausgabe des Berichts landet zudem auf dem Kanal, auf dem der
# Hook seine Entscheidung mitteilt.
set -euo pipefail
sed -i 's@stop-require-gates.sh"@stop-require-gates.sh \&\& make span-report"@' internal/emit/templates/enforce/settings.json
