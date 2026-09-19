#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestInitPfadNimmtDenZielordnerUndSonstNurFlags
# verify: test-go
#
# STELLT DIE MEHRFACH-SPERRE DES INIT-PFADS INERT: mehr als ein Positionsargument
# gilt danach als Zielordner-Paar, weil die Schranke die neuen Faelle nie erreicht.
# Der Zweig steht weiter da und uebersetzt — die Form, in der eine Sperre inert
# wird, ohne zu verschwinden.
#
# Der vertippte Unterkommando-Name (`archive-well`, plus Extra-Argument) trifft
# weder den switch in main() noch den add-lang-Zweig. Ohne die Mehrfach-Sperre
# laege der Name als Zielordner des Init-Bootstraps da; er ist kein bestehendes
# Git-Repo, also bricht der Lauf — aber an der anderen Tuere, mit einer anderen
# Meldung. Der gemessene Fall haelt die Mehrfach-Meldung (unbekanntes Argument)
# gegen den Aufruf und faerbt darum rot, auch wenn der Exit-Code zufaellig
# derselbe bleibt: die Sperre ist die Form des Abbruchs, nicht irgendein Abbruch.
#
# Der zugehoerige Fall laeuft NETZLOS (testSources-Fixture) und faellt an der
# Meldung. Die Form ohne Extra-Argument deckt der Git-Repo-Check — derselbe Test
# haelt sie mit; die Leer-Argument-Sperre hat einen eigenen Fall
# (test/mutations/377).
set -euo pipefail
sed -i 's/^\tif fs.NArg() > 1 {$/\tif fs.NArg() > 99 {/' cmd/ai-harness-init/main.go