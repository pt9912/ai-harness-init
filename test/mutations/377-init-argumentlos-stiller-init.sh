#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestUnfallVektor_OhneArgumentImRepoWurzel
# verify: test-go
#
# SCHLIESST DEN UNFALL-VEKTOR WIEDER AUF: ohne Positionsargument faellt der
# Init-Pfad danach durch die Git-Repo-Pruefung auf den stillen Init-Pfad
# zurueck, weil die Leer-Sperre die leere Argumentliste nie erreicht. Der Zweig
# steht weiter da und uebersetzt — die Form, in der eine Sperre inert wird, ohne
# zu verschwinden.
#
# Das ist der Aufruf, der den Unfall fuhr (Register-Beobachtung
# BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad): Traeger ohne
# Argument, gestanden im Repo-Wurzel-Verzeichnis eines Git-Repos. Das stehende
# Repo IST ein Git-Repo, der Check nimmt ein Ziel der Form "" als Git-Repo an
# (.git loest relativ zum Arbeitsverzeichnis auf), und bootstrap() richtet das
# stehende Repo ein — der Lauf schreibt, obwohl er laut bricht. Der gemessene
# Fall haelt die Unveraendertheit des stehenden Repos gegen denselben Aufruf am
# Prozess und faerbt rot.
#
# Die geschwaechte Zusicherung (bricht, aber schreibt) deckt derselbe Fall von
# Hand: der Zweig druckt die Usage und bootstrappt trotzdem — Exit-Code und
# Meldung stimmen, die Verzeichnis-Pruefung bleibt rot. Die run()-Faehige
# Meldungs-Haelfte haelt TestRun_OhneZielordnerBrichtLaut.
set -euo pipefail
sed -i 's/^\tif fs.NArg() == 0 {$/\tif fs.NArg() == -1 {/' cmd/ai-harness-init/main.go