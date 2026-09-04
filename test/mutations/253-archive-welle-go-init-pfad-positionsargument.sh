#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestInitPfadNimmtKeinPositionsargument
# verify: test-go
#
# SCHIEBT DIE SCHWELLE DER INIT-SPERRE AUS DER REICHWEITE: run() nimmt danach
# jedes Positionsargument wieder still an, weil fs.NArg() die neue Schranke nie
# erreicht. Der Zweig steht weiter da und uebersetzt — die Form, in der eine
# Sperre inert wird, ohne zu verschwinden.
#
# Dahinter liegt der Bootstrap. Ein Name, der weder den switch in main() noch den
# add-lang-Zweig trifft, ist in run() ein Positionsargument, das der Flag-Parser
# stehen laesst; bootstrap() legt danach ein Repo im Arbeitsverzeichnis an. Der
# Aufrufer sieht dabei eine Ausgabe und einen Exit-Code — nur die einer anderen
# Faehigkeit. Genau diese Richtung ist der Gegenstand von Fall 237, eine Stufe
# tiefer: dort trifft der `case` nicht mehr, hier gibt es fuer einen vertippten
# Namen nie einen.
#
# Der genannte Fall laeuft NETZLOS (testSources-Fixture) und faellt am Exit-Code:
# verlangt sind 2, geliefert werden 0 (Bootstrap gelungen) oder 1 (Bootstrap ohne
# Docker gescheitert). TestSubkommandoRouting_UnbekannterNameSchreibtNicht faellt
# mit — er faehrt den Traeger als Prozess und damit die echten Quellen. Als
# `# expect:` steht der netzlose Fall, weil sein Rot nur eine Ursache haben kann.
set -euo pipefail
sed -i 's/^\tif fs.NArg() > 0 {$/\tif fs.NArg() > 99 {/' cmd/ai-harness-init/main.go
