#!/usr/bin/env bash
# files: harness/tools/extract-agent-call.awk
# expect: extract: Pfad-Ausbruch im Typnamen -> exit 3
#
# Lockert den Zeichensatz des Typnamens um Punkt und Schraegstrich.
#
# Der Wert kommt aus fremder Payload, und der Extraktor gibt ihn an Aufrufer weiter,
# die ihn in einen Pfad setzen duerfen — das ist der Grund fuer die Strenge, nicht
# Kosmetik. Mit der Lockerung ist `../../etc/passwd` ein zulaessiger Typname, und
# jeder Abnehmer, der daraus einen Pfad baut, zeigt aus seinem Verzeichnis heraus.
# Die Schranke gehoert deshalb zum Wert und nicht zu einem einzelnen Abnehmer: der
# Extraktor verweigert hier (exit 3, fail-closed), statt tolerant zu sein.
#
# Rot wird in test/agent-guard.bats „Pfad-Ausbruch im Typnamen -> exit 3".
#
# Der Anker nennt den umgebenden Vergleich, nicht nur die Zeichenklasse: die Klasse
# steht auch im Kopf-Kommentar der awk-Datei, und ein Anker ohne Kontext aenderte
# beide Zeilen — die Mutation griffe dann auch am Text statt nur am Code.
set -euo pipefail
sed -i 's@stval !~ /^\[A-Za-z0-9_:-\]+\$/@stval !~ /^[A-Za-z0-9_:.\\/-]+$/@' harness/tools/extract-agent-call.awk
