#!/usr/bin/env bash
# files: harness/tools/extract-agent-call.awk
# expect: extract: Pfad-Ausbruch im Typnamen -> exit 3
#
# Lockert den Zeichensatz des Typnamens um Punkt und Schraegstrich.
#
# Der Guard baut aus `subagent_type` einen PFAD (`.claude/agents/<name>.md`) — das
# ist der Grund fuer die Strenge, nicht Kosmetik. Mit der Lockerung ist
# `../../etc/passwd` ein zulaessiger Typname; die Existenzfrage zeigte dann auf einen
# Ort ausserhalb des Verzeichnisses, und ob der Aufruf als Rolle gilt, entschiede
# eine fremde Datei. Der Extraktor muss hier verweigern (exit 3, fail-closed), nicht
# tolerant sein.
#
# Rot wird in test/agent-guard.bats „Pfad-Ausbruch im Typnamen -> exit 3".
#
# Der Anker nennt den umgebenden Vergleich, nicht nur die Zeichenklasse: die Klasse
# steht auch im Kopf-Kommentar der awk-Datei, und ein Anker ohne Kontext aenderte
# beide Zeilen — die Mutation griffe dann auch am Text statt nur am Code.
set -euo pipefail
sed -i 's@stval !~ /^\[A-Za-z0-9_:-\]+\$/@stval !~ /^[A-Za-z0-9_:.\\/-]+$/@' harness/tools/extract-agent-call.awk
