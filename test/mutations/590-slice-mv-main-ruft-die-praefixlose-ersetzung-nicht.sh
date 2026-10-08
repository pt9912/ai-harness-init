#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: TestSliceMvEchtKanteOpenNachDone
# verify: test-go
#
# NIMMT main() DEN AUFRUF DER PRAEFIXLOSEN ERSETZUNG: die Geschwister im
# Ausgangsverzeichnis werden noch gefunden, ihre Links "](<datei>)" aber nicht
# mehr umgeschrieben; sie zeigen nach dem Wechsel auf das Verzeichnis, das die
# Datei verlassen hat, und die Zeile `eingehend:` nennt 0 praefixlose Links.
#
# test/slice-mv.bats ruft rewrite_incoming_bare_in_file() selbst und bleibt
# gruen. Der Go-Test faehrt main() und liest den Ist-Bestand von open/.
#
# Der Anker steht genau einmal im Skript, als Aufruf in main()
# (grep -c 'n="$(rewrite_incoming_bare_in_file ' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~"[$](rewrite_incoming_bare_in_file "[$]sf" "[$]base" "[$]TO")"~0~' harness/tools/slice-mv.sh
